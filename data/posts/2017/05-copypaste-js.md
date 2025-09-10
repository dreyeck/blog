---
id: 1103
title: Copy&Paste JS
date: "2017-05-13 21:02:33"
categories:
  - interactive
tags:
  - javascript
  - library
  - release
language: eng
---

Particularly when making small web pages, or userscripts, I don't want to be importing huge libraries, or having to deal with cumbersome workflows that involve preprocessing. And so I find myself making little utility functions that fit my coding style, which end up being the same ones over and over. Sometimes I copy-and-paste them straight from an older project, or rewrite them altogether. At some point I decided to just collect them in a single location for easy managing and retrieval, and I might as well share that, so I made [**Copy&Paste JS.**](https://github.com/agj/copy-paste-js) This was back in 2015, and I've had the repository up on Github for some time, but I wanted to make it both easy to browse and manageable, something that took me a lot of work to figure out (plus of course a long hiatus.) Right now it's just listing utilities in ES2015-compliant (for modern platforms) and ES5-compliant (for backward-compatibility) formats, the latter mostly auto-generated from the former, and with no documentation or examples of use. I did take enough care to fully spec test every utility, and I plan on turning these specs into code that works as both documentation and tests, in addition to explaining what each one does in a brief paragraph. For now, at least they're available and fully tested.

```js
const partial =
  (f, args1) =>
  (...args2) =>
    f.apply(null, args1.concat(args2));
```

For instance, this little snippet is not difficult to write on the spot, but one might not get it right the first try. Having it there, tested and ready to use is pretty convenient. What this one is useful for is to 'prepare' a function by passing it a few arguments in advance. It returns a new function that will take the rest of the necessary arguments. Like in this example:

```js
[1, 2, 3, 4, 5].map(partial(Math.pow, [2])); //=> [2, 4, 8, 16, 32]
```
