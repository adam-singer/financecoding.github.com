---
layout: post
title: "Turning Solar3d into a Chrome App"
description: "Turning Solar3d into a Chrome App"
category: 
tags: [Dart, Example, ChromeApp]
---


Ventured tonight with creating an installable [Chrome App](https://developers.google.com/chrome/apps/docs/developers_guide) in `#dartlang`. 

I was compiling to javascript and ran into problems with `dart2js` using unsafe evals, there not allowed in Chrome Apps. 

[![unsafeevals](/images/2012-12-09-turning-solar3d-into-a-chrome-app.image.2.png)](/images/2012-12-09-turning-solar3d-into-a-chrome-app.image.2.png)

`dart2js` provides the ability to disallow them using `dart2js --disallow-unsafe-eval`. 

After another try loading up the app some funky business was going on, filed a [bug](http://goo.gl/alaAK) at [dartbug](http://dartbug.com) and within minutes someone had looked at the issue and pointed me to a [patch](http://goo.gl/d3t3e). 

Luckily the way `dart2js` is laid out in the dart-sdk a patch could be applied without side effects. Great design by the `dart2js` team, reducing the ability of needing to build from bleeding_edge. 

{% highlight bash %}
22:37:10-adam@Adams-MacBook-Air:/Applications/dart/dart-sdk
$ curl https://codereview.chromium.org/download/issue11491005_1.diff | patch -p2
patching file lib/_internal/compiler/implementation/js_backend/emitter.dart
patching file lib/_internal/compiler/implementation/js_backend/emitter_no_eval.dart
{% endhighlight %}

*Note you must remove the snapshot build of `dart2js`.* The snapshot build of dart2js providers faster load times by the VM.  

{% highlight bash %}
23:14:57-adam@Adams-MacBook-Air:~/dart/solar3d/web
$ rm -rf /Applications/dart/dart-sdk/lib/_internal/compiler/implementation/dart2js.dart.snapshot
{% endhighlight %}

Rebuilt and reloaded the application and solar3d worked as a Chrome App!

{% highlight bash %}
00:47:16-adam@Adams-MacBook-Air:~/dart/solar3d/web
$ dart2js --disallow-unsafe-eval -osolar.dart.js solar.dart
{% endhighlight %}

[![unsafeevals](/images/2012-12-09-turning-solar3d-into-a-chrome-app.image.1.png)](/images/2012-12-09-turning-solar3d-into-a-chrome-app.image.1.png)

Your welcome to checkout the minior modifications of [solar3d](https://github.com/financeCoding/solar3d) on github. Follow the instructions [Getting Started](http://developer.chrome.com/extensions/getstarted.html) with Chrome Apps on loading unpacked extentions. 
