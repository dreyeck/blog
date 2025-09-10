---
id: 868
title: Bye bye Pixelpost
date: "2014-03-28 03:16:26"
categories:
  - interactive
  - musings
tags: []
language: eng
---

Spambots were having a field day with my neglected [_piclog_ Pixelpost installation](//piclog.agj.cl/) (old picture blogging CMS, not updated in several years), and it was getting hit so ferociously that it was hogging resources and my host complained. So I took it down. But since I have a few blog posts that link to pictures over there, I fixed it. I basically scrapped Pixelpost, downloaded the database, and implemented a super simple version of it that uses [YAML](http://www.yaml.org/) files as a database and PHP. And no commenting, since it wasn't getting anything other than truckloads of spam anyway. The design and all, I couldn't be bothered to update. I did, however, change the URLs to make them a tiny bit prettier, taking care to redirect links written in the old format.
