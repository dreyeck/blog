---
title: On my elm-knobs Elm package
date: "2025-08-25 00:33:00"
categories:
  - interactive
tags:
  - elm
  - elm-knobs
  - library
  - release
  - web
language: eng
external:
  mastodon-toot-id: "115087445560231107"
  devto-slug: "on-my-elm-knobs-elm-package-162g"
---

Two years ago I made [a simple Elm package](https://elm.dmy.fr/packages/agj/elm-knobs/latest/) to scratch my own itch, named `agj/elm-knobs`. I wanted a simple interface to tweak constants dynamically in order to see how they affect a visual algorithm (which was just a project I was working on for fun; I'll post about it if I actually get around to finishing it). I found a few packages that get close to what I wanted, but nothing matching precisely my needs, so I just coded the thing and eventually turned it into a simple package.

![image](/files/2025/08-on-my-elm-knobs-elm-package/elm-knobs-screenshot.png "Screenshot of the “polygon” elm-knobs example.")

The intended use-case for the package is squarely prototyping, so I didn't put effort into making it look nice or visually versatile. What I did though is add “knobs” (interactive controls) for primitive types (`Int`, `Float`, `String`, `Bool`) and a few non-primitives.

The way it works is through a `Knob a` type value, where `a` could be any type at all, as long as you have the means to create it. This knob value contains the current value of `a` and a view function that returns HTML and emits updates to itself as an event whenever the controls get manipulated. Below is a quick rundown on how to use a knob.

```elm
knob : Knob Int
knob =
    Knob.int { step = 1, initial = 0 }

knobValue : Int
knobValue =
    Knob.value knob

type Msg =
    KnobUpdated (Knob Int)

knobView : Html Msg
knobView =
    Knob.view [] KnobUpdated knob
```

Please note that _this example code and the rest of this post are actually based on unreleased v2 code._ I guess I'll have to release that version soon, though.

And then there's ways to compose, transform and create custom knobs. You can also serialize and deserialize a knob into a string, in order to persist its value using the Web Storage API or however else you like. Some omissions I can think of are knobs for dates, and for data structures such as lists and dictionaries.

In the remainder of this blog post I'll describe a couple of ways in which I “over-developed” this package, beyond its content proper.

# Interactive documentation

This was my first Elm package, and I put a lot of effort into the documentation, taking it as a chance to learn and just make it as useful as possible. Elm core package documentation is way above average, so I took a lot of inspiration from it. I think that the [package docs](https://elm.dmy.fr/packages/agj/elm-knobs/1.2.0/Knob) I wrote are pretty clear and organized, meant to almost work as a tutorial.

One way I tried to improve the documentation was by creating [“interactive documentation”](https://agj.github.io/elm-knobs/) using [ElmBook](https://github.com/dtwrks/elm-book). It's comprised of code examples for each of the knob functions, whose resulting HTML you can see live in your browser. It's interactive in the sense that the example code shows up as interactive HTML, not in that you can tweak the code yourself, though.

One of the interesting things I did there was making sure that the example code matches what you see exactly, and that I don't have to forget to copy & paste something. Elm has no metaprogramming capabilities, so using an external tool to do this was necessary—here comes [Comby](https://comby.dev/) to the rescue! (Think [sed](https://en.wikipedia.org/wiki/Sed), but for manipulating code syntax instead of plain text.)

Take a look at the Elm code below, describing an example for `Knob.float`. Using [a very short script I wrote using Comby](https://github.com/agj/elm-knobs/blob/d0acf8c5a3d97ef714185e3f090bb33cda988ea1/scripts/update-example-code-strings.nu), the string value in the `code` field gets filled with what's in the `init_` field automatically. Having these two synchronized makes sure that example code is always valid, since otherwise the interactive docs would not compile either.

```elm
floatDoc : KnobDoc Float Model
floatDoc =
    { name = "float"
    , link = Nothing
    , description = Nothing
    , init_ =
        Knob.float { step = 0.01, initial = 0 }
    , code =
        """
        Knob.float { step = 0.01, initial = 0 }
        """
    , get = \model -> model.float
    , set = \model new -> { model | float = new }
    , toString = String.fromFloat
    }
```

Another thing you might notice from the code block above is that I used some tricks to make writing the documentation more DRY (i.e. more consistent, less error-prone). With ElmBook you write markdown to define the content of each page. I generate this markdown from records like the one you see above. [Here's the module I wrote for that purpose](https://github.com/agj/elm-knobs/blob/d0acf8c5a3d97ef714185e3f090bb33cda988ea1/interactive-docs/src/KnobDoc.elm), although it might be a bit hard to follow, especially given that it's written to accomodate the ElmBook API. But at any rate, something like the above turns into [what you see here](https://agj.github.io/elm-knobs/1.2.0/#/knob-examples/number).

![image](/files/2025/08-on-my-elm-knobs-elm-package/elm-knobs-intdoc-float.png "Screenshot of the above code as rendered in the interactive docs.")

I'm not happy with having to split the “API docs” and the “interactive docs”, so at some point I might figure out a way of automatically parsing the Elm comment docs and inserting that content into the interactive documentation, to keep it all in one place. Sounds like a lot of effort for such a relatively useless package, so if I ever end up going through the trouble, it'll be for the learning opportunity (or perhaps my OCD.)

# Property-based tests

I test all knobs using property-based tests (which in [elm-test](https://github.com/elm-explorations/test) are called “fuzzers”, although that is [the wrong term](https://en.wikipedia.org/wiki/Fuzzing)). The idea is that instead of each test checking for one or a few input values one by one against an expected result, we automatically generate a whole range of inputs, so we can make sure that our function behaves the way we expect given any possible input in the range. This technique receives this name because we can't use the same strategy for standard unit tests and just check one input against one result; we need to instead test that a given property holds.

For instance, I have a suite of serialization tests, of which there's two types:

- Something I called “transitive equality”, for lack of a better term: If two knobs correspond to the same value, the result of serializing them should also be equal, and vice-versa.
- A classic [round-trip test](https://fsharpforfunandprofit.com/posts/property-based-testing-3/#inverseRev): We serialize and then deserialize, and expect the value of the input knob and of the result to be identical.

Other tests check messages emitted when a user manipulates the controls, the behavior for invalid inputs, and such.

# Individualizing versions

Let me give you an example of a problem I frequently run into when using third-party library code. At my day job, we're using Vue and a component library called [shadcn-vue](https://www.shadcn-vue.com/). We are using v1, and recently they released v2. As soon as they did, the documentation for v1 disappeared.

I don't like this experience. I want to decide when to upgrade, and as long as I'm using an old version, I want to have access to its documentation. Two libraries in the JavaScript space that do great in this respect are [Ramda](https://ramdajs.com/) and [date-fns](https://date-fns.org/docs/). Elm packages automatically keep docs available for every version, so this is much less of a problem in our ecosystem. However, if I point a link at a `latest` URL, I'm effectively making my documentation expire.

So, all of the links to places in the documentation, including the package docs and the interactive docs, are versioned. And in order to make sure I don't forget to update any version string whenever I release a new version, I've implemented checks across the repo. For links in the readme, the [Docs.UpToDateReadmeLinks](https://package.elm-lang.org/packages/jfmengels/elm-review-documentation/2.0.4/Docs-UpToDateReadmeLinks/) [elm-review](https://github.com/jfmengels/node-elm-review) rule works great. For other cases, I wrote [a Nushell script](https://github.com/agj/elm-knobs/blob/d0acf8c5a3d97ef714185e3f090bb33cda988ea1/scripts/check-version.nu) that even checks the git tag and the changelog.

Interactive docs for older versions are also kept available in Github Pages and in compiled form in the repo.
