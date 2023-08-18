import express from "express";
import elmPagesMiddleware from "./middleware.mjs";

const app = express();
const port = 4040;

app.use(express.static("dist"));
app.use(elmPagesMiddleware);
app.listen(port, () => {
  console.log(`Listening on port ${port}`);
});
