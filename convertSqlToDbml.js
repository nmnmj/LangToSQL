// convertSqlToDbml.js
const fs = require('fs');
const path = require('path');
const { importer } = require('@dbml/core');

async function sqlToDbml(inputFile, outputFile) {
  try {
    // 1️⃣ Read the MySQL schema from the file
    const sqlContent = fs.readFileSync(inputFile, 'utf-8');

    // 2️⃣ Convert SQL to DBML
    const dbml = importer.import(sqlContent, 'mysql');

    // 3️⃣ Write DBML output to file
    fs.writeFileSync(outputFile, dbml, 'utf-8');

    console.log(`✅ DBML successfully generated: ${outputFile}`);
  } catch (error) {
    console.error('❌ Conversion failed:', error.message);
  }
}

// sqlToDbml(path.resolve("./schema.sql"), path.resolve("./schema.dbml"));

module.exports = { sqlToDbml }