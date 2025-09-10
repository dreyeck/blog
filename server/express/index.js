import fs from 'node:fs';
import path from 'node:path';
import express from 'express';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();

const roots = [
  path.join(__dirname, '..', '..', 'dist'),
  path.join(__dirname, '..', '..', 'build'),
  path.join(__dirname, '..', '..', 'public')
];
const staticRoot = roots.find(p => fs.existsSync(p)) || roots[2];

app.use(express.static(staticRoot));

app.get('*', (req, res, next) => {
  const indexFile = path.join(staticRoot, 'index.html');
  if (fs.existsSync(indexFile)) return res.sendFile(indexFile);
  return next();
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Express serving "${staticRoot}" on http://localhost:${PORT}`);
});
