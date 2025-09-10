---
title: I made Spwords again
date: "2025-08-18 00:53:00"
categories:
  - language
  - my-games
tags:
  - elm
  - release
  - spwords
  - text-game
  - video-game
language: eng
external:
  mastodon-toot-id: "115047053104100563"
---

[A game I made in 2012](/2012/12/spwords), I made it again. That's about it! [It's **playable** from the same address as before.](http://www.agj.cl/files/games/spwords/) [Here's the **code** for the new v2.](https://github.com/agj/spwords/tree/v2.0)

![image](/files/2025/08-i-made-spwords-again/spwords-screenshot.png "Screenshot of the remade Spwords")

Since the game's a bit hard to understand at first, here's the silly intro text explaining the rules, for your convenience:

> WELCOME TO TONIGHT'S EXCITING MATCH! IT'S MENACING **COMPUTER** AGAINST CROWD FAVORITE **PLAYER**! REMEMBER THE RULES: THE TWO CONTESTANTS TAKE TURNS TO TYPE WORDS THAT **START** WITH THE **ROUND'S LETTER**. THEY ALSO MUST **CONTAIN** THE **LAS[T] LETTE[R] OF THE PREVIOUS WORD**. THEN, PRESS ENTER. **NO REPEATS**, AND WATCH THE TIME LIMIT! FIRST TO SEIZE **THREE ROUNDS** IS THE VICTOR. NOW, LET THE MATCH BEGIN!

Well, I guess I'll explain a bit more. This is really old news, as I finished this “remake” back in 2023. I actually spent a few years of very occasional work on it, rewriting it from the vanilla JavaScript I made it originally in, to Elm, and slowly tweaking and improving it. As it stands currently, it's not so different from how it was back when I originally made it for the TIGSource compo. It's the same game, but it has three speeds, single and two-player hotseat (single keyboard) play modes, and more commentary text. It's also a bit prettier, too.

I remade it because I still enjoyed the concept; I think it's a cute game. I wanted to experiment with making games in Elm, and improving upon this game's source code, which I wrote in a short time when I was still not very experienced, seemed like a good idea.

The new code still doesn't leave me fully satisfied (I've grown in my experience using Elm since then, too,) but it being Elm, it's a hell of a lot nicer. I'll leave the door open for future improvements, like audio and stuff. Who knows?
