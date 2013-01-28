---
layout: post
title: "Getting started with Dart and Google Drive"
date: 2012-12-30 16:27
comments: true
categories: 
- Dart
- js-interop
- Example
- Drive
- googleapi
---

Following the example code from google drive [quickstart](https://developers.google.com/drive/quickstart-js) I was able to recreate the sample in [Dart](http://www.dartlang.org). A lot of the heavy lifting is done by the [js-interop](https://github.com/dart-lang/js-interop) cause of the dependency on [google javascript client api](http://code.google.com/p/google-api-javascript-client). This solution is fine for now, I'd take a good guess the dart team will provide client apis at some point. 

Started off by creating a new sample project `dart_drive_quickstart`, removed all default code and add js-interop.

[![create-new-app](/images/2012-12-30-getting-started-with-dart-and-google-drive/create-new-app.png)](/images/2012-12-30-getting-started-with-dart-and-google-drive/create-new-app.png) 

[![remove-defaults](/images/2012-12-30-getting-started-with-dart-and-google-drive/remove-defaults.png)](/images/2012-12-30-getting-started-with-dart-and-google-drive/remove-defaults.png) 


Bring in the javascript client apis as `ScriptElement` and set a `onload` handler to a dart callback. 

``` dart dart_drive_quickstart.dart
import 'dart:html';
import 'dart:json';
import 'package:js/js.dart' as js;

final String CLIENT_ID = '<YOURCLIENTID>';
final String SCOPE = 'https://www.googleapis.com/auth/drive';

void main() {
  js.scoped((){
    js.context.handleAuthResult = new js.Callback.many((js.Proxy authResult) {
      Map dartAuthResult = JSON.parse(js.context.JSON.stringify(authResult));
      print("dartAuthResult = ${dartAuthResult}");
    });      

    js.context.handleClientLoad =  new js.Callback.many(() {
      js.context.window.setTimeout(js.context.checkAuth, 1);
    });

    js.context.checkAuth = new js.Callback.many(() {
      js.context.gapi.auth.authorize(
          js.map({
              'client_id': CLIENT_ID,
              'scope': SCOPE,
              'immediate': true
            }),
            js.context.handleAuthResult);
    });      	
  });

  ScriptElement script = new ScriptElement();
  script.src = "http://apis.google.com/js/client.js?onload=handleClientLoad";
  script.type = "text/javascript";
  document.body.children.add(script);
}
```

Manually adding the script code and hooking up a callback from javascript to dart seemed to work fine. I ran into issues with callbacks not being scoped when they should of been scoped. Another odd thing was the need for the call to `setTimeout`, the callback to `handleAuthResult` would not get fired if `checkAuth` was not called from `setTimeout`. 

The rest of the code included was for the most part a direct translation of the quickstart sample. Added some dart flavoring when appropriate.

Here are some action shots and code. The full project can be found on github [dart_drive_quickstart](https://github.com/financeCoding/dart_drive_quickstart)

[![app-launched](/images/2012-12-30-getting-started-with-dart-and-google-drive/app-launched.png)](/images/2012-12-30-getting-started-with-dart-and-google-drive/app-launched.png) 

[![file-choose](/images/2012-12-30-getting-started-with-dart-and-google-drive/file-choose.png)](/images/2012-12-30-getting-started-with-dart-and-google-drive/file-choose.png) 

[![file-uploaded](/images/2012-12-30-getting-started-with-dart-and-google-drive/file-uploaded.png)](/images/2012-12-30-getting-started-with-dart-and-google-drive/file-uploaded.png) 

[![file-opened-in-drive](/images/2012-12-30-getting-started-with-dart-and-google-drive/file-opened-in-drive.png)](/images/2012-12-30-getting-started-with-dart-and-google-drive/file-opened-in-drive.png) 

``` dart dart_drive_quickstart.dart
import 'dart:html';
import 'dart:json';
import 'package:js/js.dart' as js;

final String CLIENT_ID = '299615367852.apps.googleusercontent.com';
final String SCOPE = 'https://www.googleapis.com/auth/drive';

void main() {
  js.scoped((){
    void insertFile(File fileData, [callback = null]) {
      String boundary = '-------314159265358979323846';
      String delimiter = "\r\n--$boundary\r\n";
      String close_delim = "\r\n--$boundary--";

      var reader = new FileReader();
      reader.readAsBinaryString(fileData);
      reader.on.load.add((Event e) {
        var contentType = fileData.type;
        if (contentType.isEmpty) {
          contentType = 'application/octet-stream';
        }

        var metadata = {
          'title' : fileData.name,
          'mimeType' : contentType
        };

        var base64Data = window.btoa(reader.result);
        var sb = new StringBuffer();
        sb
        ..add(delimiter)
        ..add('Content-Type: application/json\r\n\r\n')
        ..add(JSON.stringify(metadata))
        ..add(delimiter)
        ..add('Content-Type: ')
        ..add(contentType)
        ..add('\r\n')
        ..add('Content-Transfer-Encoding: base64\r\n')
        ..add('\r\n')
        ..add(base64Data)
        ..add(close_delim);

        var multipartRequestBody = sb.toString();

        print("multipartRequestBody");
        print(multipartRequestBody);

        js.scoped(() {
          var request = js.context.gapi.client.request(
            js.map({
              'path': '/upload/drive/v2/files',
              'method': 'POST',
              'params': {'uploadType': 'multipart'},
              'headers': {
                'Content-Type': 'multipart/mixed; boundary="$boundary"'
              },
              'body': multipartRequestBody
            }));

          if (callback == null) {
            callback = new js.Callback.many((js.Proxy jsonResp, var rawResp) {
              print(js.context.JSON.stringify(jsonResp));
              print(rawResp);

              Map r = JSON.parse(js.context.JSON.stringify(jsonResp));
              StringBuffer sb = new StringBuffer();
              if (r.containsKey('error')) {
                sb.add(r.toString());
              } else {
                sb.add("${r["title"]} has been uploaded.");
              }

              query('#text').text = sb.toString();
            });
          }

          request.execute(callback);
        });

      });
    };

    void uploadFile(Event evt) {
      js.scoped( () {
        js.context.gapi.client.load('drive', 'v2', new js.Callback.many(() {
          var file = evt.target.files[0];
          insertFile(file);
        }));
      });
    }

    js.context.handleAuthResult = new js.Callback.many((js.Proxy authResult) {
      Map dartAuthResult = JSON.parse(js.context.JSON.stringify(authResult));
      print("dartAuthResult = ${dartAuthResult}");

      var authButton = query('#authorizeButton');
      var filePicker = query('#filePicker');
      authButton.style.display = 'none';
      filePicker.style.display = 'none';

      if (!dartAuthResult.containsKey('error')) {
        // Access token has been successfully retrieved, requests can be sent to the API.
        filePicker.style.display = 'block';
        filePicker.on['change'].add(uploadFile);
      } else {
        authButton.style.display = 'block';
        authButton.on.click.add((Event e) {
          js.scoped(() {
            js.context.gapi.auth.authorize(
                js.map({
                    'client_id': CLIENT_ID,
                    'scope': SCOPE,
                    'immediate': true
                  }),
                  js.context.handleAuthResult);
          });
        });
      }
    });

    js.context.handleClientLoad =  new js.Callback.many(() {
      js.context.window.setTimeout(js.context.checkAuth, 1);
    });

    js.context.checkAuth = new js.Callback.many(() {
      js.context.gapi.auth.authorize(
          js.map({
              'client_id': CLIENT_ID,
              'scope': SCOPE,
              'immediate': true
            }),
            js.context.handleAuthResult);
    });
  });

  ScriptElement script = new ScriptElement();
  script.src = "http://apis.google.com/js/client.js?onload=handleClientLoad";
  script.type = "text/javascript";
  document.body.children.add(script);
} 
```