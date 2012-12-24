---
layout: post
title: "How to use CanvasElement.toDataURL in Dart"
description: "Using toDataURL in Dart"
categories: [Dart, Example, Canvas]
---

When looking to create an [ImageElement](http://api.dartlang.org/docs/bleeding_edge/dart_html/ImageElement.html) from a [CanvasElement](http://api.dartlang.org/docs/bleeding_edge/dart_html/CanvasElement.html)'s context, [toDataURL](https://developer.mozilla.org/en-US/docs/DOM/HTMLCanvasElement) is your friend. An example use case of this would be creating screen shots of a canvas after some routine has ended. Another could be taking a screen shot when a playing a game that was developed with context [2d](http://www.w3.org/TR/2010/WD-2dcontext-20100304/) or [webgl](http://www.khronos.org/webgl/). ```toDataURL``` returns a ```data:``` URL containing a representation of the image in the format specified by ```type``` (defaults to PNG).

The following example shows the use of canvas 2d for creating a [jpeg](http://en.wikipedia.org/wiki/JPEG) image and inserting it into the body of a document. If you run this example you might notice the loss of the alpha channel, that would be a good reason to switch to [png]() format when calling ```toDataURL```. 

<script src="https://gist.github.com/4148505.js"><!-- gist --></script>
