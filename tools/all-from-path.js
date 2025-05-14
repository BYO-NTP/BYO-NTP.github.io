#!node

import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.resolve(path.dirname(__filename), '..');

async function loadJsonFilesFromFolder(folderPath) {
  const jsonArray = [];
  try {
    const files = await fs.readdir(folderPath);

    for (const file of files) {
      const filePath = path.join(folderPath, file);

      if (path.extname(file) !== '.json') continue;

      try {
        const rawData = await fs.readFile(filePath, 'utf-8');
        const jsonData = JSON.parse(rawData);
        jsonArray.push(jsonData);
      } catch (err) {
        console.error(`Error reading or parsing ${file}:`, err);
      }
    }
  } catch (err) {
    console.error(`Error reading folder ${folderPath}:`, err);
  }

  return jsonArray;
}

const all = {};

for (const folder of ['recipes', 'server', 'os', 'gnss']) {
  const fullPath = path.join(__dirname, folder);
  all[folder] = await loadJsonFilesFromFolder(fullPath);
}

const outputDir = path.join(__dirname, 'dist');
await fs.mkdir(outputDir, { recursive: true });

try {
  const outputPath = path.join(outputDir, 'all.json');
  await fs.writeFile(outputPath, JSON.stringify(all, null, 2), 'utf-8');
  console.log(`✅ All JSON data has been written to ${outputPath}`);
} catch (err) {
  console.error('❌ Error writing to file:', err);
}
