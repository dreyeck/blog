---
id: 998
title: A constructed language
date: "2016-11-24 16:27:16"
categories:
  - language
  - musings
  - projects
tags:
  - come-to-think-of-language
  - conlang
  - japan
  - language
  - release
  - university
language: eng
---

For my Master's dissertation project in the New Media program at the Tokyo University of the Arts, I quickly devised a small constructed language, something that would be a tool for me to explore language itself in abstraction. Before I undertook the subject of human communication languages, I had been researching programming language design, and in that process came across a paradigm that was new to me, called [_concatenative._](https://en.wikipedia.org/wiki/Concatenative_programming_language) This paradigm is mathematically very elegant, structurally very simple, and in superficial appearance very similar to human written languages. I thought I could use it as a basis for a simple human language, and so I took the main ideas of it and applied them to my design.

My language is not really a language in most traditional senses, if you compare it to existing languages. It does not comprise a lexicon, nor does it have any inherent writing system, or phonetic system. It consists of just a set of rules, and they can be applied in many ways in any pertinent medium (written, oral, electric, etc.,) and is purposely unspecific about other things. It is, if you will, a framework for communication, or a protocol, more than a language as they're most often thought about.

<!-- more -->

Programming languages have an explicit feature that is implicit in most human languages, which is that you define words in order to abstract information, to provide order, or to extend the functionality of the language, and this is a very basic part of pretty much any programming language. So I took this as a main theme, and decided that my language would basically only consist of the structure, and not define anything surrounding it—words need to be defined in order to use it. So what I ended up with is a series of conditions:

- Words (individual and indivisible units of meaning) are lined-up along one dimension.
- There is one word that indicates the end of an idea, a sentence. (This might turn out to be superfluous.)
- There are two types of word: ones that represent some concept by themselves, and others, called predicates, that manipulate them.
- Predicates take some number of arguments and do some transformation on them, after which the involved words and concepts in the sentence are replaced by this new content. These arguments are the concepts that immediately precede the predicate (in linear order from the start of the sentence), and the number of arguments that it takes depends on how the predicate is defined.
- A sentence is read from beginning to end, performing any necessary transformations whenever a predicate is found, until no predicates are left.
- A gramatically sound sentence is one such that, after all transformations are done, it results in a single concept.

When I talk about concepts, I mean that the words and the concepts that they refer to are of course separate, and concepts are not necessarily representable in a single word. So after some transformation, a bunch of words may agglutinate into a single concept, and a predicate that follows it can take this resulting concept as an individual argument, despite it originally being formed by several separate words. Note that I make no assumptions on what results of the transformation, as it may be a single concept that combines the concepts that it receives as arguments, it may ignore its arguments entirely (effectively removing them), or it may return a new selection of words, out of which some may in turn be predicates that produce a chain reaction of transformations.

I also don't specify a way to define words, which means the language by necessity has an early dependence on its context. (No language is ever independent of context, though, otherwise it would not be usable for communication; it needs _grounding,_ knowledge that is shared between the involved parties.) But a predicate whose function is to define new words can be defined originally, along with words that represent elementary concepts, and a selection of predicates that combine them so that new words can be formed from then on within the language itself. This turns it into a self-depending language with [metalinguistic capabilities,](https://en.wikipedia.org/wiki/Metalanguage) like any natural language.

Let's demonstrate the use of this language with a concrete example. We're going to use emoji to write words, and a period as a sentence-end marker. Let's start by first defining a few nouns:

- ❤️: Interest.
- 📝: Language.
- ⚽️: Play (noun).
- ✊: Use (noun).

Now let's define a few predicates that will combine these:

- 🅰 🏷: Turns 🅰 into a property (adjective).
- 🅰 🏃: Turns 🅰 into an action (verb).
- 🅱 🅰 👉: Makes 🅱 the target of 🅰.
- 🅱 🅰 ⏰: 🅱 while 🅰 (simultaneity).

Using these, let's try writing some sentences.

> ❤️ 🏷 📝 👉 .
> ✊ 🏃 📝 👉 ⚽️ 🏃 ⏰ .

Going step by step, let's translate this into English. Starting with the first sentence:

> 1. ❤️ 🏷 📝 👉 .  
>    ↳ ❤️ means _interest._ 🏷 takes _interest_ and turns it into a property. Therefore…
> 2. (Interesting) 📝 👉 .  
>    ↳ 📝 means _language._ 👉 makes _language_ the target of _interesting._ Therefore…
> 3. (Interesting language → Language is interesting) .

And the second sentence:

> 1. ✊ 🏃 📝 👉 ⚽️ 🏃 ⏰ .  
>    ↳ ✊ means _use_ (noun). 🏃 turns _use_ into a verb. Therefore…
> 2. (Use [verb]) 📝 👉 ⚽️ 🏃 ⏰ .  
>    ↳ 📝 means _language._ 👉 makes _language_ the target of _use._ Therefore…
> 3. (Use language) ⚽️ 🏃 ⏰ .  
>    ↳ ⚽️ means _play_ (noun). 🏃 turns _play_ into a verb. Therefore…
> 4. (Use language) (play [verb]) ⏰ .  
>    ↳ ⏰ means that _use language_ and _play_ occur simultaneously. Therefore…
> 5. (Use language while playing → Play with language) .

Creating this language means that I have a framework devoid of ambiguities, as the rules are very simple to follow and perform (of course _not_ necessarily quickly graspable,) but with full freedom to explore linguistic expressivity, by means of the creation of predicates. Predicates are the elementary part of the grammar of this language, and them being a 'soft' element means that the language is mouldable to fit any pattern. Smart use of predicates means that we can even create different syntaxes, via the swapping around of elements.

Astute readers might realize that, despite what I described earlier, what I've laid out is in fact not enough to build a reflecting, meta-capable language, because there's no way to “quote” words in order to manipulate them literally as language entities, without them being interpreted instead for what they mean. This is something I will later think on how to best express, when I start playing with combinatory logic in the context of my language. To be specific, I've been heavily influenced particularly by the [Joy programming language,](http://www.kevinalbrecht.com/code/joy-mirror/joy.html) and [combinatory theory as applied to it (Brent Kerby).](http://tunes.org/~iepos/joy.html)

I still have a lot of research to do, as I'm by no stretch of the imagination at all knowledgeable in linguistics, so I intend to continue deepening my understanding by investigating predicate theory as it applies to linguistics, and linguistics in general. The language doesn't even have a name, because my focus is more on the way I use it. I'll be sharing that stuff in the future.
