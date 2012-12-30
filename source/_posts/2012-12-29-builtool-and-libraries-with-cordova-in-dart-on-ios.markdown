---
layout: post
title: "builtool and libraries with cordova in dart on ios"
date: 2012-12-29 21:36
comments: true
categories: 
- Dart
- Cordova
- Example
- Phonegap
- unittest
- phonegap-from-scratch
---

Continuing on the chain of [phonegap_from_scratch](/blog/categories/phonegap-from-scratch/), this post goes over [buildtool](https://github.com/dart-lang/buildtool) and libraries. 

Took an afternoon to look into using [buildtool](https://github.com/dart-lang/buildtool) for helping call dart2js on save within the DartEditor. Minor [modifications](https://github.com/financeCoding/buildtool/commit/0692911befaa5705a2928ffaa532c295191d1155) was needed to redirect the generated javascript code to the cordova `www` directory in the project. This tool is still in the works and future versions will be more robust.

The trend with dart currently is to use `pub` with github or to publish on [pub.dartlang.org](http://pub.dartlang.org/). A great feature with `pub` is if you want to make modifications to an existing project on github, `fork+branch` is an easy way to get hacking with modifications to an existing package. `buildtool`'s quick hack was added to the pubspec.yaml file as follows.

``` yaml pubspec.yaml
name:  dartdova
description:  A sample dart cordova integration
dependencies:
  js: any
  unittest: 0.2.9+7
  logging: 0.2.9+7
  buildtool:
    git:
      url: git://github.com/financeCoding/buildtool.git
      ref: diroverride
```

This pubspec.yaml pulls in the branch `diroverride` from a cloned version of `buildtool` from my github. Awesome solution for modifications that might not be upstreamed and needed quickly for testing. 

Moving along, the DartEditor will look for a `build.dart` file in the root directory of a projects folder. When that file is found it will execute on file changes within the project. `buildtool` currently provides a client/server architecture for building or transforming dart projects. The particular task I was interested in is `Dart2JSTask` which calls the dart2js compiler on modified dart files. With my modifications it now outputs the generated javascript code into the directory specified in the `Dart2JSTask.withOutDir` constructor. 

``` dart build.dart
#!/usr/bin/env dart

import 'dart:io';
import 'package:buildtool/buildtool.dart';
import 'package:buildtool/dart2js_task.dart';
void main() {
  var config = () {
    var dart2jstask = new Dart2JSTask.withOutDir("dart2js", new Path("."));
    addTask(["app.dart"], dart2jstask);
  };

  configure(config);
}
```

The way that I've approached running the server side of the `buildtool` was to launch a `./build.dart --server` process before opening the project in the DartEditor. 

``` bash output
~/dart/phonegap_from_scratch/phonegap_from_scratch/www
$ ./build.dart --server
2012-12-29 23:06:49.732 INFO adding task Instance of 'Dart2JSTask' for files [app.dart]
2012-12-29 23:06:49.757 INFO startServer
2012-12-29 23:06:49.757 INFO listening on localhost:52746
buildtool server ready
port: 52746
```

On each save in the project the server side will generate javascript code via `Dart2JSTask`.

``` bash output
2012-12-29 23:07:51.897 INFO starting build
2012-12-29 23:07:51.903 INFO cwd: /Users/adam/dart/phonegap_from_scratch/phonegap_from_scratch/www build_out/out
2012-12-29 23:07:51.909 FINE _runTasks: [_source:app.dart]
2012-12-29 23:07:51.911 INFO cwd: /Users/adam/dart/phonegap_from_scratch/phonegap_from_scratch/www build_out/_dart2js
2012-12-29 23:07:51.915 INFO dart2js task starting. files: [_source:app.dart]
2012-12-29 23:07:51.918 FINE running dart2js args: [--out=./app.dart.js, --verbose, app.dart]
2012-12-29 23:08:00.778 FINE dart2js exitCode: 0
2012-12-29 23:08:00.779 INFO dartjs tasks complete
2012-12-29 23:08:00.784 FINE tasks at depth 0 complete
2012-12-29 23:08:01.288 INFO starting build
2012-12-29 23:08:01.289 INFO cwd: /Users/adam/dart/phonegap_from_scratch/phonegap_from_scratch/www build_out/out
2012-12-29 23:08:01.291 FINE _runTasks: [_source:app.dart.js, _source:app.dart.js.deps, _source:app.dart.js.map]
2012-12-29 23:08:01.291 FINE tasks at depth 0 complete
```

This solution saves me having to run the `./build.sh` from command line and launching the iOS simulator on each launch. 

The other changes to this project was to refactor the single `app.dart` into a collection of dart library  files. Seems that each of the API categories have been implemented as singletons. At some point I may make this similar to [gap](https://github.com/rikulo/gap) where each category of API is a singleton and instantiated at the top level of a dart library. 

``` bash output
~/dart/phonegap_from_scratch/phonegap_from_scratch/www
$ tree
.
├── app.dart
├── app.dart.js
├── app.dart.js.deps
├── app.dart.js.map
├── build.dart
├── build.sh
├── cordova.js
├── dart.js
├── dart_interop.js
├── index.html
├── lib
│   └── src
│       ├── connection.dart
│       ├── cordova_events.dart
│       ├── device.dart
│       ├── globalization.dart
│       ├── notification.dart
│       └── splashscreen.dart
└── pubspec.yaml
```

New classes added `Connection`, `CordovaEvents`, `Notification`, `Splashscreen` and `Globalization`. `Globalization` is presenting a problem with knowing the proper ways to parse date strings within the javascript implementation dependent scenarios. For now I might just skip them, different javascript engines parse `Date` strings different ways and my goal was not to cover all of them. `app.dart` is now importing the libraries directly at some point a single `lib/cordova.dart` library should be provided. 

This is where my journey for tonight has ended, `Contacts` might be the next exciting class of API to cover.

The code for [phonegap_from_scratch](/blog/categories/phonegap-from-scratch/) can be found on [github](https://github.com/financeCoding/phonegap_from_scratch)