---
layout: post
title: "Using createDartAnalyzerTask in bot.dart to ensure sanity"
date: 2013-02-07 19:47
comments: true
categories: 
- Dart
- DartAnalyzer
- bot.dart
- Testing
- Drone.io
---


[drone.io](http://drone.io) has really proven to be useful for [dart](http://www.dartlang.org) projects. One common pattern I find my self doing with projects these days is running the `dart_analyzer` before running unit tests. Had a [discussion](https://github.com/kevmoo/bot.dart/issues/36) with [Kevin Moore](https://github.com/kevmoo) about having a `dart_analyzer` task included in `hop`, part of the [bot.dart](https://github.com/kevmoo/bot.dart) framework. We both agreed it would be nice to automate that task and not have shell scripts running the show. Thus [`createDartAnalyzerTask`](http://kevmoo.github.com/bot.dart/hop_tasks.html#createDartAnalyzerTask) was born. `createDartAnalyzerTask` allows you to add dart scripts that are libraries or main entry points to be analyzed by `dart_analyzer`, this allows for a first step of safety, so that code you have passes the static checker. It does not mean your code is perfect but can help you find warnings and errors. A great combination for this is pairing it up with [drone.io](http://drone.io), that way when a new sdk comes out drone can let you know automatically if it passes static checker. 

*Lets see this in action*

First step is to add bot to your `pubspec.yaml`

```yaml
dependencies:
  browser: ">=0.3.4"
  unittest: ">=0.3.4"
  bot: ">=0.12.0"
```

Create a minimal `tool/hop_runner.dart` 

```dart
library hop_runner;

import 'dart:async';
import 'dart:io';
import 'package:bot/bot.dart';
import 'package:bot/hop.dart';
import 'package:bot/hop_tasks.dart';

void main() {
  //
  // Analyzer
  //
  addTask('analyze_lib', createDartAnalyzerTask(['lib/stats.dart']));

  //
  // Hop away!
  //
  runHopCore();
}
```

Add a `bin/hop` script to your project, `bin/hop` script is not required but does help manage some flags you might be interested in having. 

```bash
#!/bin/bash
PACK_DIR=`pwd`/packages/
cmd="dart
--enable_asserts
--enable_checked_mode
--enable_type_checks
--error_on_malformed_type
--package-root=$PACK_DIR
--verbose_debug
--warning_as_error
./tool/hop_runner.dart $@"
exec $cmd
```

Now `hop` away!

```
19:41:54-adam@Adams-MacBook-Air:~/dart/stats.dart
$ hop analyze_lib
analyze_lib: PASSED - lib/stats.dart
analyze_lib: PASSED: 1, WARNING: 0, ERROR: 0
Finished
```

Now lets say we have the following warning of `String i = 42;`, bot can provide us a summary of warnings we might have in our code. 

```dart
library not_cool_lib;

void main() {
  String i = 42;
}
```

Adding the library to our task

```dart
  //
  // Analyzer
  //
  addTask('analyze_lib', createDartAnalyzerTask(['lib/stats.dart', 'lib/notcoollib.dart']));
```

Executing `hop`

```
20:04:55-adam@Adams-MacBook-Air:~/dart/stats.dart
$ hop analyze_lib
analyze_lib: PASSED - lib/stats.dart
analyze_lib: WARNING - lib/notcoollib.dart
analyze_lib: PASSED: 1, WARNING: 1, ERROR: 0
Finished
```

Now we have a warning, but since dart is a dynamic langauge we should not treat that as an error _(at some point we might provide the option of making warnings fail [drone.io](http://drone.io))_. 

If we introduce a real error, the task runner should yell at us. 

```dart
library not_cool_lib;

void main() {
  String i = 42;
  bam(i);
}
```

And it does! 

```
20:11:38-adam@Adams-MacBook-Air:~/dart/stats.dart
$ hop analyze_lib
analyze_lib: PASSED - lib/stats.dart
analyze_lib: ERROR - lib/notcoollib.dart
analyze_lib: PASSED: 1, WARNING: 0, ERROR: 1
analyze_lib: Failed
Failed
20:18:11-adam@Adams-MacBook-Air:~/dart/stats.dart
$ echo $?
80
```

The exit code will let [drone.io](http://drone.io) know that we did not exit cleanly. I love [drone.io](http://drone.io) for this reason, it's simple to get setup right away with little fuss. 

A complete run on [drone.io](http://drone.io) might look something as follows

```
$ git clone git://github.com/Dartist/stats.dart.git /home/ubuntu/src/github.com/Dartist/stats.dart 
Cloning into '/home/ubuntu/src/github.com/Dartist/stats.dart'...
$ dart --version
Dart VM version: 0.3.4.0_r18115 (Tue Feb  5 05:53:42 2013)
$ cat $DART_SDK/revision
18137
$ sudo start xvfb
xvfb start/running, process 1017
$ pub install
Resolving dependencies...
Downloading browser 0.3.4...
Downloading bot 0.12.1...
Downloading unittest 0.3.4...
Downloading logging 0.3.4...
Downloading args 0.3.4...
Downloading meta 0.3.4...
Dependencies installed!
$ export PATH=./bin:$PATH
$ hop analyze_lib
analyze_lib: PASSED - lib/stats.dart
analyze_lib: PASSED: 1, WARNING: 0, ERROR: 0
Finished
$ hop headless_test
unittest-suite-wait-for-done
headless_test: DumpRenderTree - test/tests_browser.html
headless_test: 1 PASSED, 0 FAILED, 0 ERRORS
Finished
```

For a full example of a project that uses [bot.dart](https://github.com/kevmoo/bot.dart) for testing and analyzer please refer to [stats.dart](https://github.com/Dartist/stats.dart)
