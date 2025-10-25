const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');

/**
 * Convert DBML file to ERD image (SVG/PNG)
 * @param {string} inputDbmlPath - Path to input DBML file
 * @param {string} outputImagePath - Path to output image file
 * @returns {Promise<void>}
 */
function dbmlToErd(inputDbmlPath, outputImagePath) {
  return new Promise((resolve, reject) => {
    // Make sure paths are absolute
    const inputPath = path.resolve(inputDbmlPath);
    const outputPath = path.resolve(outputImagePath);

    // Check if ERD already exists
    if (fs.existsSync(outputPath)) {
      console.log(`ℹ️ ERD already exists at: ${outputPath}, skipping generation.`);
      return resolve();
    }

    // Build CLI command
    const cmd = `npx @softwaretechnik/dbml-renderer -i "${inputPath}" -o "${outputPath}"`;

    exec(cmd, (error, stdout, stderr) => {
      if (error) {
        return reject(new Error(`Failed to generate ERD: ${stderr || error.message}`));
      }
      console.log(`✅ ERD generated at: ${outputPath}`);
      resolve();
    });
  });
}

// Example usage
// (async () => {
//   try {
//     await dbmlToErd('./schema.dbml', './erd/schema.svg');
//   } catch (err) {
//     console.error(err.message);
//   }
// })();

module.exports = { dbmlToErd };
