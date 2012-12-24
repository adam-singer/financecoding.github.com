---
layout: post
title: "How to communicate with chrome.* API in Dart"
description: "How to communicate with chrome.* API in Dart. Note bleeding edge topic, may not apply in the future."
category: 
tags: [Dart, Example, ChromeApp, chrome.*]
---

I had the privilege to attend [Chrome Apps Accelerated MTV](https://plus.google.com/+GoogleChromeDevelopers/posts/d8q3ffNhjBE) hackathon. The goal set out for my self was to create a bluetooth scanner via [chrome.bluetooth](http://developer.chrome.com/apps/bluetooth.html) api. 

First I started off by reviewing the [Chrome app](https://developers.google.com/chrome/apps/docs/developers_guide) developer guide. From a previous [post](http://financecoding.github.com/2012/12/09/turning-solar3d-into-a-chrome-app/), a patch for [7228](http://goo.gl/alaAK) was needed at the time. 

Second was too communicate with the js defined context which Chrome Apps execute in. Some setup ceremony is needed such as a [manifest](http://developer.chrome.com/extensions/manifest.html) file and [background window](https://developers.google.com/chrome/apps/docs/background). Creating the manifest file was easy, mostly choosing permissions and adding the entry Javascript background entry. 

<script src="https://gist.github.com/4263547.js"><!-- gist --></script>

For dart we will need to create the background javascript that loads our dart application.

<script src="https://gist.github.com/4263559.js"><!-- gist --></script>

I stumbled with the communications between dart generated javascript and js-interop for some time. The first part of the stumbling blocks was [CSP](http://developer.chrome.com/extensions/contentSecurityPolicy.html) (Content Security Policy) and how dart2js apps are loaded. Thanks to [Vijay Menon](https://plus.google.com/114045999004646044580) and [Renato Mangini](https://plus.google.com/102180419759627664875), I was able to create successful call and callback from dart to javascript. This was non trivial since it required knowledge of [dart.js](https://dart.googlecode.com/svn/branches/bleeding_edge/dart/client/dart.js) and loading of dart_interop.js/js.dart. 

The diff file below removes the reference to [localStorage](http://goo.gl/ojkEW) and replaces it with a map. 

<script src="https://gist.github.com/4263581.js"><!-- gist --></script>

[dart_interop.js](http://goo.gl/oYRFx) and [js.dart](http://goo.gl/g6qq6) needed to be copied into the root folder of the project. Not sure exactly why this is, very possible that only dart_interop.js is needed since were compiling to js. 

<script src="https://gist.github.com/4267476.js"><!-- gist --></script>

The first sanity check of being able to communicate with dart in a Chrome App was printing out the permissions from [chrome.permissions.getAll](https://developer.chrome.com/apps/permissions.html)

<script src="https://gist.github.com/4267502.js"><!-- gist --></script>

Google searches lead me to the wrong api docs for accessing the bluetooth device. Managed to land on [chrome.experimental.bluetooth](http://developer.chrome.com/extensions/experimental.bluetooth.html) from [extensions api](https://developer.chrome.com/extensions/api_index.html), which is different from the [Chrome Apps chrome.* api](http://developer.chrome.com/apps/api_index.html). Bug was filed about how easy it was to land on the wrong api pages. 

Now that I've got the right context too loaded, calling the chrome.bluetooth api produced errors with bluetooth support on MacOSX. doh! Bluetooth is currently only supported on ChromeOS and Windows. This was not mentioned in any of the docs and bug was filed on that. 

```
Error during bluetooth.isAvailable: This operation is not supported on your platform 
chromeHidden.handleResponse
```

At this point I was glad to be able to make calls on chrome.* api, in a following post I will go over a more complete sample from start to finish. Feel free to browse code and project structure [bluetooth_example_chrome_app](http://goo.gl/sDj6i). Please note this is not a fully working sample and has bugs!

By the end of the hackathon I decided my best bet was to package something that did not rely on the chrome.* api so heavily. An [ASCII camera capture app](http://goo.gl/wDnql) was created and demoed. The application accesses the client's video input device and converts images capture to [ascii images](http://en.wikipedia.org/wiki/ASCII_art) based on a [ascii art formula](http://mattmik.com/articles/ascii/ascii.html). "videoCapture" permissions are required for accessing video input, this was set in the manifest file. The [ASCII camera capture app](http://goo.gl/wDnql) code is available on the following branch [chrome_app_example](http://goo.gl/45UDj). 
