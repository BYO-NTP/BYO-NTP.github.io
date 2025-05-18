import { exec } from 'child_process';
import http from 'node:http';
import fs from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const port = 8080;
const htdocs = path.join(__dirname, '..', 'htdocs');

const mimeTypes = {
  '.html': 'text/html',
  '.js': 'application/javascript',
  '.css': 'text/css',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.gif': 'image/gif',
  '.txt': 'text/plain'
};

const server = http.createServer(async (req, res) => {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'OPTIONS, POST, GET',
    'Access-Control-Max-Age': 2592000,
    'Access-Control-Allow-Headers': '*',
    'Access-Control-Request-Method': '*',
  };

  console.log(`Request URL: ${req.url}`);

  let urlPath = req.url.startsWith('/recipes') ? req.url.replace(/^\/recipes/, '') || '/' : req.url;
  let filePath = path.join(htdocs, urlPath === '/' ? '/index.html' : urlPath);
  const extname = path.extname(filePath).toLowerCase();
  const contentType = mimeTypes[extname] || 'application/octet-stream';

  try {
    const content = await fs.readFile(filePath);
    res.writeHead(200, {
      'Content-Type': contentType,
      ...headers
    });
    res.end(content);
  } catch (err) {
    if (err.code === 'ENOENT') {
      res.writeHead(404, { 'Content-Type': 'text/plain', ...headers });
      res.end('404 Not Found');
    } else {
      res.writeHead(500, headers);
      res.end('Server Error');
    }
  }
});

exec('node tools/all-from-path.js', (error, stdout, stderr) => {
  if (error) {
    console.error(`Error: ${error.message}`);
    return;
  }
  if (stderr) {
    console.error(`Stderr: ${stderr}`);
    return;
  }
  console.log(`Output:\n${stdout}`);
});

server.listen(port, () => {
  const hostname = os.hostname() || 'localhost';
  console.log(`Server running at http://${hostname}:${port}/`);
});

