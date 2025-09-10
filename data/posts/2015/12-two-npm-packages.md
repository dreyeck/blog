---
id: 976
title: Two npm packages
date: "2015-12-02 16:21:30"
categories:
  - interactive
tags:
  - dot-into
  - function-promisifier
  - javascript
  - library
  - release
language: eng
---

I decided to try my hand at creating and releasing some reusable code. I have a big inferiority complex on my code quality, but I've been getting over it little by little just by piling information on my brain. So, while I've had [a Github account](https://github.com/agj) for some years (though only decided to actually start using it much recently), this is my first time offering some of my code on a module repository. So I created two tiny npm packages (that means Javascript) that do only one thing, and might prove useful to people other than myself.

The first is called **[dot-into,](https://www.npmjs.com/package/dot-into)** and it does something icky for most Javascript programmers; extending prototypes. It's still under your control, as you can choose what prototype(s) to extend, but its power comes from extending the 'holy' _Object_ prototype; that is, basically every object's root prototype. All it does is put there an 'into' method that allows you to effectively reorder terms to fit a left-to-right flow, when you would otherwise be nesting functions. That is to say:

> ```
> third(second(first(a), b));
> // becomes
> first(a).into(second, b).into(third);
> ```

I didn't come up with this on my own, though, as it was [Raganwald's idea in Ruby](http://weblog.raganwald.com/2008/01/no-detail-too-small.html) that made me want it in Javascript. He also made [a library](https://github.com/raganwald/Katy) that offers this, but also more baggage that I didn't want.

The other one's called **[function-promisifier.](https://www.npmjs.com/package/function-promisifier)** It's a utility function that takes a sync function and spews out one that takes optionally promises instead of plain values, and returns a promise instead of the result value directly, making it entirely async-compatible. It's one thing that I once wished existed, and when I looked I couldn't find it, so I made it.

I guess I'll be doing this again and releasing more code modules some time. We'll see.
