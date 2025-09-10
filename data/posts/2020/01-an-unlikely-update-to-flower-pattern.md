---
id: 1150
title: An unlikely update to Flower Pattern
date: "2020-01-23 02:22:17"
categories:
  - interactive
  - my-games
tags:
  - flower-pattern
  - javascript
  - release
  - video-game
language: eng
---

Although I released it in 2012, over seven years ago now, [_Flower pattern_](/2012/11/flower-pattern/) is actually still one of my favorite digital things I've made. It's simple, feels good to play around with for a bit, and it's impactful to show to people. It's not the deepest, it just looks cool.  So the fact that because of evolving technologies it's sort of aging poorly is not something I'm happy with. For one, back then I didn't own a smartphone, so it was poorly tested on them, and actually looks really cramped. Higher pixel density displays also became the norm since then, and my toy looks blurry on them. Then some DOM API changes means that on touch devices there's issues with touch events…

Change all of that to the past tense now, cause I just fixed it! It's looking much better now, in time for my upcoming portfolio update. **[Check it out](http://agj.cl/ip/fp)** at the same address as before: `http://agj.cl/ip/fp`

As I set out to do this, I was afraid that the code would be an undecipherable mess, but it was all actually fairly well structured. I long abandoned the actionscript 3-informed OOP style that I used in it, but all in all it was fairly painless to work with. So given that, I decided to [throw **the code** up on Github](https://github.com/agj/flowerpattern/) with an open source license. It's a really dated coding style, with mock-class hierarchy and using old javascript libraries and all, but I guess parts of it can be useful to someone, like the drawing code. Anyway, no harm with it being open for people to check out and maybe copy.
