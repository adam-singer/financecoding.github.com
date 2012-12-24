---
layout: post
title: "Getting started with Dart and Cordova from scratch on iOS"
description: ""
categories: 
- Dart
- Cordova
- Example
- Phonegap
---

Looking for some fun this weekend I decided to investigate the current status of using dart and cordova together.

Breif history of Dart and Cordova comes down to two projects, [solvr/dart-gap](https://github.com/Solvr/dart-gap) and [rikulo/gap](https://github.com/rikulo/gap) have ventured into creating a frameworks for dart and cordova interop. [rikulo](http://rikulo.org/) has latest release, decided to give it a spin. After some tinkering I had no luck with rikulo's gap.

I decided to go down the route of finding the most minimal amount of dart code needed for loading cordova apps. A major step forward for working with cordova was the introduction of [js-interop](https://github.com/dart-lang/js-interop). js-interop will provide the communications needed between cordova.js context and the dart application. This example just gets the `'deviceready'` event fired off from `cordova.js`. 

Download the phonegap [build](http://phonegap.com/download) and unpack into a folder.

{% highlight bash %}
$ mkdir ~/dart/phonegap_from_scratch/
$ cd ~/dart/phonegap_from_scratch/
$ unzip ~/Downloads/phonegap-phonegap-2.2.0-0-g8a3aa47.zip
$ mv phonegap-phonegap-8a3aa47 phonegap
{% endhighlight %}

This is mostly done on [MacOSX](http://docs.phonegap.com/en/2.2.0/guide_getting-started_ios_index.md.html#Getting%20Started%20with%20iOS)

Setup and create a phonegap project

{% highlight bash %}
$ ./create ~/dart/phonegap_from_scratch/phonegap_from_scratch com.phonegap.from.scratch phonegap_from_scratch
{% endhighlight %}

Open up `Xcode` and do a sanity check with the default generated project from the `create` script.

{% highlight bash %}
$ open /Applications/Xcode.app
{% endhighlight %}

[![open_project_dialog](/images/2012-12-23-phonegap-from-scratch-images/open_project_dialog.png)](/images/2012-12-23-phonegap-from-scratch-images/open_project_dialog.png)

[![sanity_check](/images/2012-12-23-phonegap-from-scratch-images/sanity_check.png)](/images/2012-12-23-phonegap-from-scratch-images/sanity_check.png)

Remove all the files in `www`, rename `cordova-2.2.0.js`.

{% highlight bash %}
$ cd ~/dart/phonegap_from_scratch/phonegap_from_scratch/www/
$ rm -rf css img index.html js spec res spec.html
$ mv cordova-2.2.0.js cordova.js
{% endhighlight %}

Create a dart project in the `www` directory. This is not a typical dart package layout but works well for building and debugging. A real project might need some type of build scripts that call `dart2js` and copy files over to the `www` directory in the cordova generated project.

<script src="https://gist.github.com/4366847.js"><!-- gist --></script>

<script src="https://gist.github.com/4366855.js"><!-- gist --></script>

<script src="https://gist.github.com/4366906.js"><!-- gist --></script>

<script src="https://gist.github.com/4367140.js"><!-- gist --></script>

Install the `pub` dependencies. The `dart.js` and `dart_interop.js` need to be stored locally within the cordova project.

{% highlight bash %}
~/dart/phonegap_from_scratch/phonegap_from_scratch/www
$ pub install
Resolving dependencies...
Dependencies installed!

$ cp packages/js/dart_interop.js .
$ wget https://dart.googlecode.com/svn/branches/bleeding_edge/dart/client/dart.js
{% endhighlight %}

[![opening_dart_editor](/images/2012-12-23-phonegap-from-scratch-images/opening_dart_editor.png)](/images/2012-12-23-phonegap-from-scratch-images/opening_dart_editor.png)

[![dart_project_layout](/images/2012-12-23-phonegap-from-scratch-images/dart_project_layout.png)](/images/2012-12-23-phonegap-from-scratch-images/dart_project_layout.png)

Having little success with the other projects it took some time to figure out a proper way to load all the js files. Some combinations would not yield the `‘deviceready’` event expected from cordova. The loading order that worked best for me was `cordova.js`, `dart.js`, `dart_interop.js` and then the actual application `app.dart.js`. Running the build script and loading up the simulator should yeild some output on the console.

This is just the start of exploring integrations between dart and cordova. At least until the existing projects have an easier solution to bootstraping with their frameworks.

[![most_minimal_event_deviceready](/images/2012-12-23-phonegap-from-scratch-images/most_minimal_event_deviceready.png)](/images/2012-12-23-phonegap-from-scratch-images/most_minimal_event_deviceready.png)

Full example can be found on github [phonegap_from_scratch](https://github.com/financeCoding/phonegap_from_scratch).
