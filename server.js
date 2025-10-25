const express = require("express");
const bodyParser = require("body-parser");
const OpenAI = require("openai");
const fs = require("fs");
const path = require("path");
const mysql = require("mysql2/promise");
const { sqlToDbml } = require("./convertSqlToDbml");
const { dbmlToErd } = require("./dbmlToErd");
require("dotenv").config();
const app = express();
app.use(bodyParser.json());

// ---------- CONFIG ----------
const SCHEMA_FILE = "./schema.sql";
const ERD_DIR = path.join(__dirname, "erd");


// ---------- Create MySQL pool ----------
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: 17213,
  ssl: {
    rejectUnauthorized: false, // Aiven requires SSL
  },
  // ssl: {
  //   ca: fs.readFileSync("./ca.pem"), // use your CA certificate
  // },
});

// convert sql to dbml
sqlToDbml(path.resolve("./schema.sql"), path.resolve("./schema.dbml"));

// convert dbml to erd
dbmlToErd("./schema.dbml", "./erd/schema.svg");

const LOG_FILE = path.join(__dirname, "logs.json");

if (!fs.existsSync(ERD_DIR)) fs.mkdirSync(ERD_DIR);

// ---------- 2️⃣ SQL Validator ----------
function validateSQL(sql) {
  if (!sql) return false;
  const forbidden = ["DROP", "DELETE", "INSERT", "UPDATE"];
  const upper = sql.toUpperCase();
  return !forbidden.some((op) => upper.includes(op));
}

// ---------- 3️⃣ Logging ----------
function logRequest(inputQuery, response) {
  const entry = {
    timestamp: new Date().toISOString(),
    inputQuery,
    response,
  };
  let logs = [];
  if (fs.existsSync(LOG_FILE)) {
    logs = JSON.parse(fs.readFileSync(LOG_FILE));
  }
  logs.push(entry);
  fs.writeFileSync(LOG_FILE, JSON.stringify(logs, null, 2));
}

// ---------- 4️⃣ Route ----------
app.post("/translate", async (req, res) => {
  try {
    const { query } = req.body;
    const schema = fs.readFileSync(SCHEMA_FILE, "utf-8");

    const prompt = `
You are a SQL translator. Convert English to SQL for the schema below.
Schema:
${schema}

Rules:
1. Never hallucinate tables/columns.
2. Only read-only queries (no DROP, DELETE, INSERT, UPDATE).
3. For ambiguous queries, output JSON with {"generatedSQL": null, "clarify": "<your question>"}.
4. Output JSON ONLY in this exact format:
{
  "inputQuery": "${query}",
  "generatedSQL": "<SQL query>",
  "sqlExplanation": "<explanation of query>",
  "tablesUsed": ["<tables used>"],
  "columnsUsed": ["<columns used>"],
  "filtersApplied": [
    { "column": "<column>", "operator": "<operator>", "value": "<value>" }
  ],
  "erdImage": "${path.resolve("./erd/schema.svg")}"
}

Input query: "${query}"
`;
    const openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY,
    });
    const completion = await openai.chat.completions.create({
      model: "gpt-3.5-turbo-16k",
      messages: [
        {
          role: "user",
          content: prompt,
        },
      ],
    });

    console.log(completion.choices[0].message.content);
    let parsed;
    try {
      parsed = JSON.parse(completion.choices[0].message.content);
    } catch {
      return res.status(500).json({ error: "Invalid JSON returned by GPT" });
    }

    if (!validateSQL(parsed.generatedSQL)) {
      return res.status(400).json({
        error: "SQL contains forbidden operations (DROP/DELETE/INSERT/UPDATE)",
      });
    }

    // ---------- Execute SQL on Aiven MySQL ----------
    let sqlResult = null;
    if (parsed.generatedSQL) {
      const [rows] = await pool.query(parsed.generatedSQL);
      sqlResult = rows;
    }
    parsed.sqlResult = sqlResult; 

    parsed.inputQuery = query;
    logRequest(query, parsed);

    res.json(parsed);
  } catch (err) {
    console.error("❌ Error:", err);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

// ---------- 5️⃣ Start Server ----------
app.listen(3000, () => console.log("🚀 Server running on port 3000"));
