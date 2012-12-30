---
layout: post
title: "event handling and logging with cordova in dart on iOS"
date: 2012-12-27 00:22
comments: true
categories: 
- Dart
- Cordova
- Example
- Phonegap
- unittest
- phonegap-from-scratch
---

Continuing on the chain of [phonegap_from_scratch](/blog/categories/phonegap-from-scratch/) this post goes over event handlers and logging. 

Adding logging was trivial with the [`logger`](http://pub.dartlang.org/packages/logging) library on pub. Adding the following dependencies and setup configuration code was just enough to help with logging tests and code.

``` yaml pubspec.yaml
name:  dartdova
description:  A sample dart cordova integration
dependencies:
  js: any
  unittest: 0.2.9+7
  logging: 0.2.9+7
```

``` dart configureLogging
void configureLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.on.record.add((LogRecord r) {
    // Print to console.log when compiled to javascript.
    print("${r.loggerName}:${r.level.name}:${r.sequenceNumber}:\n${r.message.toString()}");
  });
}
``` 

Cordova ships with a list of custom [events](http://docs.phonegap.com/en/2.2.0/cordova_events_events.md.html#Events) that can be fired off to the dom. The common pattern is to add event handlers to these events. Luckily we can receive the events without having to register handles with js-interop.  

	deviceready
	pause
	resume
	online
	offline
	backbutton
	batterycritical
	batterylow
	batterystatus
	menubutton
	searchbutton
	startcallbutton
	endcallbutton
	volumedownbutton
	volumeupbutton


I've noticed a few of them need to be hooked really early in the loading of a dart application. One `deviceready` being critical for knowing when the device is ready. If they are not hooked early in the application you could miss the event. At least I've noticed that with the iOS simulator. 

``` dart main
void main() {
  /**
   * Cordova.js will fire off 'deviceready' event once fully loaded.
   * listen for the event on js.context.document.
   *
   * This must be the first event wired up before creating Device.
   */
  document.on['deviceready'].add(deviceReady);
}
```

`online`, `offline`, `battery*` are also events that one might want to catch early in `main()`. Later in the application after `deviceready` has been fired off you can remove the old handlers and add new ones that relate to the context created. 

The design pattern for `Device` is a singleton which left me with having event handlers registered whenever any newed references go out of scope. This works for now, another approach for event handling could of been to use [Reactive-Dart](https://github.com/prujohn/Reactive-Dart) `Observable` object.

```dart Device

/** The device: Singleton */
class Device {
  static final Device _singleton = new Device._internal();

  Logger _logger;
  js.Proxy _device;

  factory Device() {
    return _singleton;
  }

  Device._internal() {
    _logger = new Logger("Device");

    _registerHandlers();

    js.scoped(() {
      _device = js.context.device;
      js.retain(_device);
    });

  }

  void _registerHandlers() {
    _onOnlineHandlers = new List<Function>();
    document.on['online'].add(_onOnline);

    _onOfflineHandlers = new List<Function>();
    document.on['offline'].add(_onOffline);
  }

  String get name => js.scoped(() => _device.name);
  String get cordova => js.scoped(() => _device.cordova);
  String get platform => js.scoped(() => _device.platform);
  String get uuid => js.scoped(() => _device.uuid);
  String get version => js.scoped(() => _device.version);

  List<Function> _onOnlineHandlers;
  List<Function> get onOnline => _onOnlineHandlers;
  void _onOnline(Event event) => _onOnlineHandlers.forEach((handler)=>handler(event));

  List<Function> _onOfflineHandlers;
  List<Function> get onOffline => _onOfflineHandlers;
  void _onOffline(Event event) => _onOfflineHandlers.forEach((handler)=>handler(event));
}
``` 

Creating tests for this type of pluming was not too difficult using [`expectAsync1`](http://api.dartlang.org/docs/bleeding_edge/unittest.html#expectAsync1). The most of time spent on figuring this out was creating [`CustomEvent`](http://api.dartlang.org/docs/bleeding_edge/dart_html/CustomEvent.html) and calling [`dispatch`](http://api.dartlang.org/docs/bleeding_edge/dart_html/EventListenerList.html#dispatch). This is enough functionality to see that device was properly wired up with handlers. I found it important to cover lots of tests when working with Cordova, error handling and reporting is very minimal. At times something would stop working with no console output. So I move forward with code and test in tandem.

``` dart runTests
    test('Device Event online', () {
      var eventName = 'online';
      var asyncMethod = expectAsync1((Event event)=>expect(event.type, equals('$eventName')));
      var customEvent = new CustomEvent('$eventName', true, false, "custom event");
      var device = new Device();
      device.onOnline.add(asyncMethod);
      document.on['$eventName'].dispatch(customEvent);
    });

    test('Device Event offline', () {
      var eventName = 'offline';
      var asyncMethod = expectAsync1((Event event)=>expect(event.type, equals('$eventName')));
      var customEvent = new CustomEvent('$eventName', true, false, "custom event");
      var device = new Device();
      device.onOffline.add(asyncMethod);
      document.on['$eventName'].dispatch(customEvent);
    });
``` 

[![unittest_pass](/images/2012-12-27-event-handling-and-logging-with-cordova-in-dart-on-ios/unittests_passing.png)](images/2012-12-27-event-handling-and-logging-with-cordova-in-dart-on-ios/unittests_passing.png)

So far this is a good enough to have a device class and event handlers for custom events. The single [`app.dart`](https://github.com/financeCoding/phonegap_from_scratch) is starting to get large, next it should be broken out. I integrated the event handling directly in the `Device` class, but the Cordova [API Reference](http://docs.phonegap.com/en/2.2.0/index.html) keeps them at the top level of the application. So a singleton `Events` or `CordovaEvents` class might be useful to separate the implementation out.

A project that is just starting to hit the [dart-lang](https://github.com/dart-lang/) github repository is [buildtool](https://github.com/dart-lang/buildtool). `buildtool` might provide a better solution then having a custom build script that needs to be called before each launch of the simulator. 

The code for [phonegap_from_scratch](/blog/categories/phonegap-from-scratch/) can be found on [github](https://github.com/financeCoding/phonegap_from_scratch)