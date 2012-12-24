---
layout: post
title: "Ways to solve the N doors N passes question"
description: ""
category: 
tags: [Dart, Math, Brainteaser]
---

Question
--------
  1000 doors in a row that are initially closed. 
  1000 passes on the doors. Each time you visit 
  a door you toggle it. If open->close, if close->open. 
  First time you visit every door, second time 
  you visit every other door, third time you visit 
  every 3rd door, etc.. until visiting all 1000 doors. 
  How many doors are left open at the end? Which are open, 
  which are closed? What is unique about the sequence left open?

Solutions
---------

The O(n^2) solution to the problem which presents interesting results in its output. 

<script src="https://gist.github.com/4041693.js"><!-- gist --></script>

The O(n) solution that takes advantage of a known identity of [perfect squares](http://en.wikipedia.org/wiki/Square_number) ![](http://rosettacode.org/mw/images/math/d/0/4/d04596032dd6404083d3653514ef825a.png) found in the problem. 
 
<script src="https://gist.github.com/4141261.js"><!-- gist --></script>


