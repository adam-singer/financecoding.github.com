---
layout: post
title: "rikulo stream on heroku"
date: 2013-03-09 07:16
comments: true
categories: 
- Dart
- Heroku
- Rikulo
- Stream
---

Tonights hacking was with [stream][] and [heroku][]. _Stream is a Dart web server supporting request routing, filtering, template technology, file-based static resources and MVC design pattern._ I just planned on serving static content from [heroku][] using full dart based web server. 

First setup the dart build pack

```bash shell
adam@Adams-MacBook-Air:~/dart
$ mkdir stream_todomvc

adam@Adams-MacBook-Air:~/dart/stream_todomvc 
$ cd stream_todomvc

adam@Adams-MacBook-Air:~/dart/stream_todomvc
$ heroku create stream-todomvc

adam@Adams-MacBook-Air:~/dart/stream_todomvc
$ heroku config:add BUILDPACK_URL=https://github.com/igrigorik/heroku-buildpack-dart.git

adam@Adams-MacBook-Air:~/dart/stream_todomvc
$ git init

adam@Adams-MacBook-Air:~/dart/stream_todomvc
$ git remote add heroku git@heroku.com:stream-todomvc.git
```

Creating a new project called `stream-todomvc`. Going to use the [todomvc][] from the [web-ui][] project as our content for the [stream][] server. First thing that should be done is adding the dependencies to the `pubspec.yaml` file. 

```yaml pubspec.yaml
name: stream_todomvc
description: A sample WebUI application
dependencies:
  browser: any
  js: any
  web_ui: 0.4.1+7
  stream: 0.5.5+1
```

Next I simply compied the existing [todomvc][] project out into my [stream-todomvc][] project.

```bash shell
adam@Adams-MacBook-Air:~/dart/stream_todomvc
$ cp ~/dart/web-ui/example/todomvc/* ./web/
``` 

[stream intro][] documentation goes over some basic configurations and settings. I'm just going to use them for now to get something running right away. The key to note when serving code from the `web/` folder in dart projects is having the [stream][] server code in `web/webapp/`. That way [stream][] can find all your resources with little configuration. With very little dart code we can have static web server going. 

```dart web/webapp/server.dart
library server;

import 'dart:io';
import "package:stream/stream.dart";

void main() {
  var port = Platform.environment.containsKey('PORT') ? int.parse(Platform.environment['PORT']) : 8080;
  var host = '0.0.0.0';
  var streamServer = new StreamServer();
  streamServer
  ..port = port
  ..host = host
  ..start();
}
```

Since this was a [web-ui][] project we need to have a `build.dart` file help us with transforming the polyfill web components. 

```dart build.dart
import 'dart:io';
import 'package:web_ui/component_build.dart';

main() => build(new Options().arguments, ['web/index.html']);
```

The [heroku][] environment requires a [procfile][] configuration to let the service know the type of commands to run.

```text Procfile
web: ./dart-sdk/bin/dart --package-root=./packages/ web/webapp/server.dart
```

Next we build all the static data for our webapp to function. This will include calling `build.dart` and `dart2js`. The second step of calling `dart2js` helps with clients that do not have the `dartvm` built in. 

```bash shell
adam@Adams-MacBook-Air:~/dart/stream_todomvc
$ pub install
Resolving dependencies...
Dependencies installed!

adam@Adams-MacBook-Air:~/dart/stream_todomvc
$ dart build.dart 
Total time spent on web/index.html                           -- 839 ms
Total time                                                   -- 863 ms      

adam@Adams-MacBook-Air:~/dart/stream_todomvc
$ dart2js -oweb/out/index.html_bootstrap.dart.js web/out/index.html_bootstrap.dart
Using snapshot /Users/adam/Documents/DartEditor/dart/dart-sdk/lib/_internal/compiler/implementation/dart2js.dart.snapshot
```

Now everything should be ready for deployment.

```bash shell
adam@Adams-MacBook-Air:~/dart/stream_todomvc
$ git add -a -m "ready for deploy"

adam@Adams-MacBook-Air:~/dart/stream_todomvc
$ git push -v --set-upstream heroku master:master 
Pushing to git@heroku.com:stream-todomvc.git
Counting objects: 5, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 283 bytes, done.
Total 3 (delta 2), reused 0 (delta 0)

-----> Fetching custom git buildpack... done
-----> Dart app detected
-----> Installing Dart VM, build: latest
-----> Copy Dart binaries to app root
-----> Install packages
*** Found pubspec.yaml in .
Resolving dependencies...
Dependencies installed!
Fixed web symlink
-----> Discovering process types
       Procfile declares types -> web

-----> Compiled slug size: 8.9MB
-----> Launching... done, v7
       http://stream-todomvc.herokuapp.com deployed to Heroku

To git@heroku.com:stream-todomvc.git
   042f1f4..b35984b  master -> master
updating local tracking ref 'refs/remotes/heroku/master'
```

Deploying to [heroku][] in this style is just a good starting point. [web-ui][] and [dart][] in general is still working on a deployment story. The URL for the [stream-todomvc][] will contain `out` in its location, not very desirable. In the future a [buildtool][] will aid the deployment story for [dart][]. 

Check out the live version of [stream-todomvc][] with full source code available at the [stream-todomvc github project][].

[buildtool]: https://github.com/dart-lang/buildtool
[dart]: http://www.dartlang.org
[procfile]: https://devcenter.heroku.com/articles/procfile
[todomvc]: https://github.com/dart-lang/web-ui/tree/master/example/todomvc
[web-ui]: https://github.com/dart-lang/web-ui
[heroku]: http://www.heroku.com/
[stream]: https://github.com/rikulo/stream
[stream intro]: http://docs.rikulo.org/stream/latest/Getting_Started/Introduction.html
[stream-todomvc]: http://stream-todomvc.herokuapp.com/out/index.html
[stream-todomvc github project]: https://github.com/financeCoding/stream-todomvc