---
id: 753
title: Flower pattern
date: "2012-11-29 21:15:12"
categories:
  - my-games
tags:
  - flower-pattern
  - javascript
  - release
  - video-game
language: eng
---

![image](/files/2012/11-flower-pattern/flowerpatternscreen.jpg "Flower pattern screenshot")

Here's an HTML5 drawing toy I've been working on for a few weeks. It's been designed to work on touch devices in addition to the plebian mouse, although I only really have my iPad to try it on, so I'm not sure how it will work everywhere else. You can add it to the home screen on any iOS apparatus, and it'll work more or less like a regular app, offline and all.

[**Play _Flower pattern_**](//www.agj.cl/files/games/flowerpattern/) (web, touch devices)

For your phone or tablet, and for your convenience, I also set up a shorter URL: `http://agj.cl/ip/fp` . Caveat: based on one report, it doesn't seem to work properly on older versions of iOS.

<!-- more -->

This was my first foray into several HTML5 APIs: the canvas element, touch events, and the application cache. I also came up with a way to imitate actionscript 3's brand of class-based inheritance in javascript, and used that to port my code over. It was painful (you're free to peek at the code if curious).

Although I've worked on this toy for this relatively short period of time, the truth is that it has its origins in a much earlier Flash toy I made for my sister. It had different modes, though; 'star' mode remains largely the same, but the rest are different. There was a form of 'chain' mode there, although it didn't link up the strokes following their orientation, so it was much less interesting to look at (current implementation I stole from a concept by [zaphos](https://sites.google.com/site/zaphos/)). The one other mode just repeated what you drew around the screen, rotated randomly.

The code for that I later used as basis for [_Intervalo..._](//www.agj.cl/games/#game:intervalo), for which I created different ways to expand on what you drew. I took ideas in that for this, as well.

There were some things I couldn't achieve using canvas that I'd managed with Flash —dealing with color blendings and pixel-level operations with any speed,— but I'm still happy with how this turned out. Hope you enjoy it.
