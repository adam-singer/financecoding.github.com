---
layout: post
title: "Unit Testing with Dart and Cordova on iOS"
date: 2012-12-25 23:37
comments: true
categories: 
- Dart
- Cordova
- Example
- Phonegap
- unittest
---

Continuing on from [phonegap_from_scratch](2012/12/23/getting-started-with-dart-and-cordova-from-scratch-on-ios) post, the next step forward for building stuff with Dart and Cordova was to get some unit testing. First class to test is [Device](http://docs.phonegap.com/en/2.2.0/cordova_device_device.md.html#Device). The tests created here are specific to the platform and simulator. Did not add any of the device events for testing until I can find a way to generate them from the simulator. 

First step is to add unit testing to the pub spec file. 

{% highlight yaml %}
name:  dartdova
description:  A sample dart cordova integration
dependencies:
  js: any
  unittest: 0.2.9+7
{% endhighlight %}

Going with `useHtmlEnhancedConfiguration()` from `unittest/html_enhanced_config.dart` did not work. Cordova or iPhone simulator seems to swallow up any exceptions or failures in rending, so resorting to the more stripped down version `useHtmlIndividualConfiguration()` from `package:unittest/html_individual_config.dart`.

Using [gap](https://github.com/rikulo/gap) as a reference it was easy enough to create a working [singleton](http://stackoverflow.com/questions/12649573/how-do-you-build-a-singleton-in-dart) Device class.

{% gist 4381449 %}

Now building the js code with `build.sh` and launching iPhone simulator in `Xcode.app`, the passing unit test should be displayed in the simplified version of the [unittest](http://www.dartlang.org/articles/dart-unit-tests/) output. 

{% gist 4381488 %}

[![unittest_pass](/images/2012-12-25-unit-testing-with-dart-and-cordova-on-ios/unittestpass.png)](/images/2012-12-25-unit-testing-with-dart-and-cordova-on-ios/unittestpass.png)