import tailwindcss from "tailwindcss";
import autoprefixer from "autoprefixer";
import { elmReviewTailwindCssPlugin } from "elm-review-tailwindcss-postcss-plugin";
import sass from "@csstools/postcss-sass";

export default {
  syntax: "postcss-scss",
  plugins: [
    sass(),
    tailwindcss(),
    autoprefixer(),
    elmReviewTailwindCssPlugin(),
  ],
};
