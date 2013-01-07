---
layout: post
title: "Listing files with Google Drive and Dart"
date: 2013-01-06 18:23
comments: true
categories: 
- Dart
- js-interop
- Example
- Drive
- googleapi
---

Moving forward with my curiosity of Google [drive](/blog/categories/Drive/) and [Dart](/blog/categories/Dart/), today was spent creating a small [sample](https://github.com/financeCoding/dart_drive_files_list) that lists files. For the most part this is a continuation of the following post [getting-started-with-dart-and-google-drive](/blog/2012/12/30/getting-started-with-dart-and-google-drive/).  

Decided to move the loading of [client.js](http://code.google.com/p/google-api-javascript-client/) into its own helper class for now. When dart has real support for Google client apis none of this will be needed. As of now this serves as good practice and examples of javascript/dart interop. 

``` dart dart_drive_files_list.dart
/**
 * Sample google api client loader.
 */
class GoogleApiClientLoader {
  static const String _CLIENT_ID = '299615367852.apps.googleusercontent.com';
  static const String _SCOPE = 'https://www.googleapis.com/auth/drive';
  static const String _handleClientLoadName = "handleClientLoad";

  static void _loadScript() {
    /**
     * Create and load script element.
     */
    ScriptElement script = new ScriptElement();
    script.src = "http://apis.google.com/js/client.js?onload=$_handleClientLoadName";
    script.type = "text/javascript";
    document.body.children.add(script);
  }

  static void _createScopedCallbacks(var completer) {
    js.scoped((){
      /**
       * handleAuthResult is called from javascript when
       * the function to call once the login process is complete.
       */
      js.context.handleAuthResult = new js.Callback.many((js.Proxy authResult) {
        Map dartAuthResult = JSON.parse(js.context.JSON.stringify(authResult));
        completer.complete(dartAuthResult);
      });

      /**
       * This javascript method is called when the client.js script
       * is loaded.
       */
      js.context.handleClientLoad =  new js.Callback.many(() {
        js.context.window.setTimeout(js.context.checkAuth, 1);
      });

      /**
       * Authorization check if the client allows this
       * application to access its google drive.
       */
      js.context.checkAuth = new js.Callback.many(() {
        js.context.gapi.auth.authorize(
            js.map({
              'client_id': _CLIENT_ID,
              'scope': _SCOPE,
              'immediate': true
            }),
            js.context.handleAuthResult);
      });

    });
  }

  /**
   * Load the google client api, future returns
   * map results.
   */
  static Future<Map> load() {
    var completer = new Completer();
    _createScopedCallbacks(completer);
    _loadScript();
    return completer.future;
  }
}
```

The calling of `load()` returns a future with our authentication results. Eases the process of having the google drive scope available to the client application. 

A simple dart `Drive` class created gives access to the list call from the javascript apis. The interesting point for me to learn is knowing that `client.js` has to load the drive api. In the `load()` future we call `js.context.gapi.client.load` which will take the api and version to be loaded for the client application. 

``` dart dart_drive_files_list.dart
/**
 * Sample google drive class.
 */
class Drive {
  js.Proxy _drive;
  bool get _isLoaded => _drive != null;

  /**
   * Load the gapi.client.drive api.
   */
  Future<bool> load() {
    var completer = new Completer();
    js.scoped(() {
      js.context.gapi.client.load('drive', 'v2', new js.Callback.once(() {
        _drive = js.context.gapi.client.drive;
        js.retain(_drive);
        completer.complete(true);
      }));
    });
    return completer.future;
  }

  /**
   * Check if gapi.client.drive is loaded, if not
   * load before executing.
   */
  void _loadederExecute(Function function) {
    if (_isLoaded) {
      function();
    } else {
      load().then((s) {
        if (s == true) {
          function();
        } else {
          throw "loadedExecute failed";
        }
      });
    }
  }

  /**
   * List files with gapi.drive.files.list()
   */
  Future<Map> list() {
    var completer = new Completer();
    _loadederExecute(() {
      js.scoped(() {
        var request = _drive.files.list();
        request.execute(new js.Callback.once((js.Proxy jsonResp, var rawResp) {
          Map m = JSON.parse(js.context.JSON.stringify(jsonResp));
          completer.complete(m);
        }));
      });
    });
    return completer.future;
  }
}
```

With the following sugar classes it was easy to just list files from my google drive account. 

``` dart dart_drive_files_list.dart
void main() {
  Drive drive = new Drive();
  GoogleApiClientLoader.load().then((result) {
    drive.list().then((Map files) {
      // https://developers.google.com/drive/v2/reference/files/list
      files['items'].forEach((i) {
        var li = new LIElement();
        AnchorElement a = new AnchorElement();
        a.href = i['alternateLink'];
        a.target = '_blank';
        a.text = i['title'];
        li.children.add(a);
        UListElement ul = query('#listmenu');
        ul.children.add(li);
      });
    });
  });
}
```

[![listing-files-drive](/images/2013-01-06-listing-files-with-google-drive-and-dart/listing_files_google_drive.png)](images/2013-01-06-listing-files-with-google-drive-and-dart/listing_files_google_drive.png) 

Hopefully this helps with developers interested in google drive & dart! Sample can be found on github [dart_drive_files_list](https://github.com/financeCoding/dart_drive_files_list) 