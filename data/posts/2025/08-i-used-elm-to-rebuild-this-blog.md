---
title: I used Elm to rebuild this blog
date: "2025-08-06 04:34:00"
categories:
  - interactive
  - musings
tags:
  - blog
  - elm
  - nix
  - web
language: eng
external:
  mastodon-toot-id: "114979973656685360"
---

Wow, it's been five years!

I grew tired of the old Wordpress blog long ago, and that's one of the reasons I stopped posting. The design wasn't responsive, so anyone looking at it from a smartphone would get a terrible experience. I don't need a fancy design, but the thought of sharing a link to an article here was just embarrassing to me. I admit it doesn't look amazing right now, but it's readable! It even has light and dark modes, for the fussy crowd.

Like I mentioned, the old one was made using Wordpress. I could've kept it like that, but the thought of further fiddling with the PHP templates wasn't very appealing. Then again, I knew that reworking the entire thing required a lot of work. In the end, actually getting it done took me, it seems, about two and a half years of off-and-on work, until now, when I have it in a state I'm happy enough with.

The trigger to getting it past the finish line was Wordpress actually dying on me. (That's the reason I'm not putting up a screenshot of it for posterity. Too much work to get it working locally just for that.) This site is served from some old shared hosting I've stayed on for the longest time, and they move things under my feet often enough. One of those cases was removing older versions of PHP, and it seems that was the culprit. So I got rid of the Wordpress installation, finished the new thing, and now it's up. It's actually been sitting like this for a couple of months now, I just haven't actually gotten around to writing anything new.

You might think I could get a replacement done in a day if I used Jekyll or one of those simple blog generators, so what's the big issue? One of the reasons it was a decent amount of work to rebuild is that I wanted links to remain functional, and in general stuff to remain about as it originally was as possible. Not appearance-wise, but functionally, mostly links. Just the stuff I care about, of course. Comments had to go, because it's now a static website built from Markdown files. And I made it largely from scratch, because I did want stuff to work the way I want it to rather than wrestling control out of a a prepackaged solution.

Let me talk a bit about that!

# How it's built

So [I've been using Elm](https://blog.agj.cl/tag/?t=elm), the programming language, since 2018 now. A good few years already, sadly never for work, but for any personal project that involves the web, I've used it. So of course I wanted to use it for this blog as well. Since I didn't want to manage a backend, I chose to build a static site, so the natural fit for that was the [elm-pages](https://elm-pages.com/) framework. I started making it with v2, but then v3 stabilized so I migrated over. Yeah, it took me a bit to finish this thing.

elm-pages was originally only a static site generator that allows one to more or less build one's website as if it was a regular SPA using [the Elm architecture](https://guide.elm-lang.org/architecture/), but the HTML is generated for us and then “hydrated” with interactivity. By v3 it also gained backend capabilities, so one could use the framework for a full-stack website built entirely in Elm. Sounds nice, but all of that new stuff goes unused in this here blog—I'm barely just using the static site parts.

The framework is greatly capable. Full-stack Elm is an amazing promise, and it seems to deliver, though I have no experience to that effect. The experience I do have, however, has had its highs and its lows. The main low points are the confusing documentation and the flaky setup, which tends to break in opaque ways if one touches something one shouldn't. But once one makes sense of it, the architecture is very flexible, and simply a great idea. I really like the “backend task” concept, which is just code that runs when compiling, allowing us to read files or fetch remote resources to pre-generate static data. For instance, what I do is read the .md files using a glob selector, parse the path, parse the file's frontmatter YAML, parse the markdown, and then I have all the data I need to build the routes, the indices, and of course the posts. You might get the general idea if you take a look at [the relevant file in my Github repo](https://github.com/agj/agj-blog/blob/451759322ca95524344ca7912dd2cd1b4c4b55d5/src/Data/Post.elm) which deals with reading and parsing posts.

Other relevant technology I used: Clojure to parse the Wordpress XML export data and convert it to markdown, TypeScript for a few tiny bits I couldn't get done with just Elm, and Tailwind CSS for styles.

Oh yeah, take a look at the [source code](https://github.com/agj/agj-blog) if you're interested. The development environment is setup using [Nix](https://nixos.org/), so it's nice and reproducible, no fiddling with versions of dependencies and whatnot. I think I'll write a post one of these days about how I configure my projects using Nix flakes, Just and Nushell.
