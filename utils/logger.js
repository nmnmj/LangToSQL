const fs = require('fs');
const path = require('path');

function logRequest(inputQuery, response) {
    const logPath = path.join(__dirname, '../logs.json');
    const logData = {
        timestamp: new Date().toISOString(),
        inputQuery,
        response
    };
    let logs = [];
    if (fs.existsSync(logPath)) logs = JSON.parse(fs.readFileSync(logPath));
    logs.push(logData);
    fs.writeFileSync(logPath, JSON.stringify(logs, null, 2));
}

module.exports = { logRequest };
