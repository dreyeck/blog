---
id: 22
title: Making a game about making
date: "2008-11-06 19:50:17"
categories:
  - my-games
  - projects
tags:
  - campodecolor
  - final-years-project
  - flash
  - graphic-design
  - interactive
  - university
  - video-game
  - web
language: eng
---

In [a previous post](/2008/10/13/ambitions-of-pushing-the-envelope/) I explained what motivated me to make the game I am currently making as my final project in college. In this entry I will actually describe what I have achieved so far, and my plans for what's to come. If you so wish, you may [**play the game**](//www.agj.cl/files/games/viscomp1/), incomplete as it is, before reading what follows. If you do, I'd be very interested in hearing about your experience, how you approached the game without knowing exactly what it was about, what could have been clearer or better.

What I sought, as I explained in that other post, was to create a game whose main objective is not to rack up points, but to create a visual composition. This is a game about creativity, indeed; a subset of games that, I have found, is not very largely represented. ((I counted 14 games I could qualify as requiring creative input in the top 100 games of a series of specialized publications, as compiled by [Kirk Israel](http://kisrael.com/vgames/powerlist/).)) Kenichi Nishi [said something in an interview](http://www.cubed3.com/news/7456) that I quote here because I consider to be extremely significant:

> Recently, games have been 'passively interactive.' Users do not really have to think about what to do; they are guided around until they reach the end of the level. These types of games do not rely on the creativity of the users.

This is why I started to consider my idea more important than at first. Although there have been games like Mario Paint, that are like tools that are given a context of fun, I wanted to make something simpler, something abstract and more concentrated. There was also the question about how this would work as a game; I didn't want it to become a color-matching, chain-making fest, so how to evaluate what was being made for its own sake? It didn't need to be competitive, but it also needed a purpose, a _raison d'être_. There was the possibility of it being multiplayer, and people judging each-others compositions, much like the abovementioned Nishi's own game, [Archime-DS](http://www.agetec.com/LOLgame/product.htm) (or LOL, as it's being brought over to this half of the world). I took a bit of that idea, as I will explain later, but I deliberated some more until I came to the conclusion that the best would be not to judge quality, but to evaluate _compositive characteristics_, or _parameters_, as I've grown used to calling them. The point being that every visual composition can be evaluated in terms of different characteristics, like how symmetric it is, whether it uses warm or cool colors, whether it is rhythmic or not (presence of visual patterns), etc. We can use these parameters to objectively determine if a composition is harmonic and pleasing to the eye, if it is foreboding, if it is unsettling, etc.

Personally, I am more of a supporter of holistic rather than reductionist approaches to analysis, but in this particular case (and in many others) it is much simpler to compartmentalize the data---especially given that I am hardly a mathematician, or even a programmer, so it simply made my work a lot easier. I realize that to this point I'm still talking abstractly, so let me show you the game proper.

![Screenshot](/files/2008/11-making-a-game-about-making/screena.png "Game of visual composition screenshot")

That is what it currently looks like. In the center, but leaning toward the top and left, is the _canvas_: a grid where the player creates his composition. To the right is the _carousel_; sort of a conveyor belt of colored groups of circles, that the player can grab at any time and drop on the canvas. In a bar at the bottom there are a series of pictograms of differing sizes: they are actually dynamic, and change depending on the current characteristics of the composition, as perceived by the game (right now the algorithms that calculate this are not very finely tuned). Each pictogram changes to either a neutral, high or low graphic depending on the value: For instance, the fire icon indicates that the colors are mostly warm, and it would change to a snowflake if it was the opposite. Its comparatively small size means that it is not leaning that much toward warmth. The pictograms still need some work for them to be easier to understand, since, as I said in that previous post of mine, this game will use no words, so they need to be self-sufficient. Finally, in the bottom right is the time counter, which, when depleted, will prompt the game to show a results screen, which is pictured below.<!-- more -->

![Screenshot](/files/2008/11-making-a-game-about-making/screenb.png "Game of visual composition screenshot")

Other than removing elements that are not needed anymore, one of the things that has changed here is that the pictograms got a line drawn around them. A full circle means a full mark; the third pictogram, indicating asymmetry, has a top value, so that shining effect is drawn to bring attention to it. The meaning behind this is an attempt to cue the player into noticing what his composition is best described as: in this case, as asymmetric. Had it been completely symmetric (i.e. the opposite of the current value), the visual result would have been the same. I based this idea around the famous expressionistic adage, best described by Gaugin's own words:

> How do you see this tree? Is it really green? Use green, then, the most beautiful green on your palette. And that shadow, rather blue? Don't be afraid to paint it as blue as possible.

Meaning that the more exaggerated a feature is, the purer, the more aesthetically relevant it becomes.

But anyway, what do these scores mean, ultimately? They are not supposed to be a reward in themselves. For any creation application, there should be a way to record what was achieved, and in the case of my game, something in that vein is planned. Specifically, there will be an online gallery where compositions made by everyone who has played the game are uploaded to, and where they are sorted visually, like a spectrum, according to the values of their parameters. What this allows is for instant comparison. If the player does not understand what a specific pictogram stands for, maybe they will come to understand it after seeing both ends of the spectrum of its parameter. They might learn what each parameter does to their own perception of the aesthetic characteristics of a composition, and put that knowledge to use in their future compositions. Though I don't make any claims that this is a proper educational game, as that carries a heavier load, the player should hopefully learn ---through iteration and comparison, and bit by bit--- something about visual composition and aesthetics. But if that doesn't happen, I will be happy enough to know that people are exercising their creativity.

Another aspect of this game, related both to helping spread the word about the game and to its enjoyment, is a social factor. As there is already a (planned) gallery system, the player will be able to also choose to record their creations to their name. By doing this, they will have access to a personal gallery of their works, which they can then, for instance, display in their blog using a 'widget', use as an avatar in a forum, and other such uses; these stem from the very natural human need for expression and communication.

That is the current state, and the future, of my game. Other planned features include:

- A name!
- Audio.
- More parameters.
- Indications overlaid on the composition for each parameter, during the results screen. For instance, if the composition was found to be symmetric, hovering over that pictogram will show, on top of the canvas, what the axis (or axes) of symmetry is/are.

Remember that you can [**play the game**](//www.agj.cl/files/games/viscomp1/) in its current state if you wish. I'd be grateful for any comments you may have on it.
