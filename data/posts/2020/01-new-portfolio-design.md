---
id: 1156
title: New portfolio design
date: "2020-01-24 19:03:37"
categories:
  - interactive
tags:
  - elm
  - portfolio
  - web
language: eng
---

![image](/files/2020/01-new-portfolio-design/portfolio.png)

Since I do so much different kinds of work, I wanted to have a portfolio that let me exhibit that variety as a strength, but without having the reader wade through a lot of chaff they're not interested in. For that reason I came up with [this new design](http://agj.cl/portfolio/), which has a short self-introduction littered with tappable keywords that bring up a list of related works. I'm using [Elm](https://elm-lang.org/) and [elm-ui](https://github.com/mdgriffith/elm-ui) for it, both of which are great. [The source code I also put up on Github](https://github.com/agj/portfolio).

It took me a while to get it to this stage of completeness, so I just put it up, but there is at least one serious bug remaining. When watching it on certain smartphone browsers, rotating the device causes the layout to glitch out—text displays in an incorrect size, things get positioned strangely, etc. I hope to get it fixed quick…
