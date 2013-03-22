---
layout: post
title: "Dart Multi Touch Canvas With Realtime APIs"
date: 2013-03-21 18:19
comments: true
categories: 
- Dart
- Google
- Realtime
- API
- Drive
---

[Google][] has made the [realtime][] api available for developers. Realtime api provides [operational transformation][] on [strings][], [lists][], [maps][] and custom [objects][]. The application data gets stored on Google Drive and is available from any supported browser. This is going to be the tooling of the future for collaborative applications. 

I took some time to see what it would take for implementing a sample realtime application in dart. Also wanted to make sure my sample could run on mobile chrome. 

Since realtime api is new, dart bindings don't really exist. Lucky for us we have [js-interop][] library. The [js-interop][] library provides communications to existing javascript code from dart. I consider this mostly a quick hack to get started with the realtime api until a more native interface exists.

The sample [realtime_touch_canvas][] demonstrates a multi touch canvas surface that updates in realtime with all clients that have the application open. 

<iframe width="560" height="315" src="http://www.youtube.com/embed/xArfJdOb55Q" frameborder="0" allowfullscreen></iframe>

Most of the heavy lifting is done by [`rtclient.dart`](https://github.com/financeCoding/realtime_touch_canvas). I ported the [code](https://github.com/googledrive/realtime-playground/blob/master/js/realtime-client-utils.js) from the javascript version. Its enough code to get started right away but a more structured solution should be done. The main class is `RealTimeLoader` used for realtime loading.

```dart
  rtl = new RealTimeLoader(clientId: 'CLIENTID.apps.googleusercontent.com', apiKey: 'KEY');
  rtl.start().then((bool isComplete) {
    /* RealTimeLoader has authenticated the application and is ready to load a file */
    loadRealTimeFile(fileId, model.onFileLoaded, model.initializeModel);
  });
```

`model.onFileLoaded` and `model.initializeModel` handle the creating of model data and loading of model data. 

In the [realtime_touch_canvas][], model data was a simple list of json strings. The ticky part here is you need to remember that your working with the realtime api within the javascript vm. So an array needs to be allocated from [js-interop][]. 

```dart
  void _createNewModel(js.Proxy model) {
    var list = model.createList(js.array(_defaultLines));
    model.getRoot().set(_linesName, list);
  }
```

After the model is created we then get called to load the file. Loading the file for our purposes is binding the collaborative objects. Some tricky things to note here is we are retaining the javascript objects so we can access them after exit of the callback. Also the callbacks have to be wrapped within [js-interop][] `js.Callback.many` proxy object. The callbacks `_linesOnAddValuesChangedEvent` and `_linesOnRemovedValuesChangedEvent` are fired off when the collaborative list object has items added or removed.

```dart
  js.Proxy _doc;
  String _linesName = "lines";
  js.Proxy _lines;

  void _bindModel(js.Proxy doc) {
    _doc = doc;
    js.retain(_doc);
    _lines = doc.getModel().getRoot().get(_linesName);
    _lines.addEventListener(gapi.drive.realtime.EventType.VALUES_ADDED, new js.Callback.many(_linesOnAddValuesChangedEvent));
    _lines.addEventListener(gapi.drive.realtime.EventType.VALUES_REMOVED, new js.Callback.many(_linesOnRemovedValuesChangedEvent));
    js.retain(_lines);
  }
```

When the callback is called the data would be in the javascript virtual machine so we can parse it and store in our native dart code. This is more of a convenience then a must do, that way we can expose plan old dart objects to our other parts of the dart application.  

```dart
  void _linesOnAddValuesChangedEvent(addedValue) {
    var insertedLine = _lines.get(addedValue.index);
    var line = new Line.fromJson(insertedLine);
    realtimeTouchCanvas.move(line, line.moveX, line.moveY);
  }
``` 

Now when we want to store a line in the application we simply convert it to json and push it into the collaborative list. The little tick here is to make sure we are `scoped` when accessing the `_lines` object since it lives in the javascript virtual machine.

```dart
  void addLine(Line line) {
    js.scoped(() {
      _lines.push(line.toJson());
    });
  }
```

The [realtime_touch_canvas][] is live on github gh-pages and [realtime_touch_canvas source][] is available.   

[js-interop]: http://pub.dartlang.org/packages/js
[lists]: https://developers.google.com/drive/realtime/reference/gapi.drive.realtime.CollaborativeList
[maps]: https://developers.google.com/drive/realtime/reference/gapi.drive.realtime.CollaborativeMap
[objects]: https://developers.google.com/drive/realtime/reference/gapi.drive.realtime.CollaborativeObject
[strings]: https://developers.google.com/drive/realtime/reference/gapi.drive.realtime.CollaborativeString
[operational transformation]: http://en.wikipedia.org/wiki/Operational_transformation
[Google]: https://developers.google.com/drive/
[googledrive]: https://github.com/googledrive
[realtimeplayground]: https://realtimeplayground.appspot.com/
[realtime]: https://developers.google.com/drive/realtime/
[realtime_touch_canvas]: http://financecoding.github.com/realtime_touch_canvas/web/index.html
[realtime_touch_canvas source]: https://github.com/financeCoding/realtime_touch_canvas



