const fs = require('fs');
const path = require('path');
const express = require('express');

const app = express();

// Prefer built output; fall back to public/
const roots = [
  path.join(__dirname, '..', '..', 'dist'),   // vite/elm-pages build
  path.join(__dirname, '..', '..', 'build'),  // alt build dir
  path.join(__dirname, '..', '..', 'public')  // smoke/manual assets
];
const staticRoot = roots.find(p => fs.existsSync(p)) || roots[2];

app.use(express.static(staticRoot));

// SPA fallback if index.html exists
app.get('*', (req, res, next) => {
  const indexFile = path.join(staticRoot, 'index.html');
  if (fs.existsSync(indexFile)) return res.sendFile(indexFile);
  return next();
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Express serving "${staticRoot}" on http://localhost:${PORT}`);
});
