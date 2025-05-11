const fs = require('node:fs');
const path = require('node:path');

function loadJsonFilesFromFolder(folderPath) {
  const jsonArray = [];

  const files = fs.readdirSync(folderPath);

  for (const file of files) {
    const filePath = path.join(folderPath, file);

    if (path.extname(file) !== '.json') continue

    const rawData = fs.readFileSync(filePath, 'utf-8');
    try {
      const jsonData = JSON.parse(rawData);
      jsonArray.push(jsonData);
    } catch (err) {
      console.error(`Error parsing JSON in file ${file}:`, err);
    }
  };

  return jsonArray;
}

const all = {}
for (const folder of ['recipes', 'server', 'os', 'gnss' ]) {
  all[folder] = loadJsonFilesFromFolder(`./${folder}`);
}

fs.writeFile(`./dist/all.json`, JSON.stringify(all, null, 2), 'utf-8', (err) => {
  if (err) {
    console.error('Error writing to file:', err);
  } else {
    console.log(`All JSON data has been written to ./dist/all.json`);
  }
})
