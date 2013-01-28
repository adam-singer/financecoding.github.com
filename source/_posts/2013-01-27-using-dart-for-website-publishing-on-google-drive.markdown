---
layout: post
title: "Using Dart for Website Publishing on Google Drive"
date: 2013-01-27 00:38
comments: true
categories: 
- Drive
- Dart
- UrlShortener
- Markdown
- GoogleApi
---

After watching a [Generating a Google Drive Hosted Website with tools you have lying around in your kitchen](http://www.youtube.com/watch?v=T56eZ1lg2oE) by [Ali Afshar](https://plus.google.com/118327176775959145936) I got interested in doing the same thing with dart.

Had to ask my self a few questions first?

* Can the [discovery_api_dart_client_generator][] create drive_v2_api code that would allow us to access drive from the console?
* Can dart process markdown?
* Can we make the [webViewLink][] easier to read and share?


At the time I started this investigation the [discovery_api_dart_client_generator][] did not have [OAuth2](https://developers.google.com/accounts/docs/OAuth2#installed) support for installed applications. Knowing that [pub][] does use OAuth2 in a similar fashion, I decided to peek inside of [pub][] to see what it is doing. 

After reviewing the [pub][] [source code](https://github.com/dart-lang/bleeding_edge/tree/master/dart/utils/pub), it's interested to see how they handle getting tokens from the Google OAuth2 Authorization Server back to the client application. [pub][] first checks if the client applications has a `~/.pub-cache/credentials.json` file stored, if the `credentials.json` is not found or invalid pub will generate an authorization url. The authorization url is copied and pasted by the user into a web browser and asks the user if they will allow access to some scopes. When the user accepts access the redirect url with token the Google OAuth2 Authorization Server redirects to a listening http server on localhost. This server was started by the [pub][] application, now [pub][] has the token and stores it for later use. 

```
12:22:46-adam@Adams-MacBook-Air:~/dart/stats.dart
$ pub publish
Publishing "stats" 0.0.4:
|-- .gitignore
|-- AUTHORS
|-- LICENSE
|-- README.md
|-- asset
|   |-- stats_dart_fps.png
|   '-- stats_dart_ms.png
|-- example
|   |-- basic
|   |   |-- statsdart.dart
|   |   '-- statsdart.html
|   '-- theming
|       |-- theming.dart
|       '-- theming.html
|-- lib
|   |-- src
|   |   '-- stats.dart
|   '-- stats.dart
|-- pubspec.yaml
'-- test
    |-- run.sh
    |-- tests_browser.dart
    '-- tests_browser.html

Looks great! Are you ready to upload your package (y/n)? y
Pub needs your authorization to upload packages on your behalf.
In a web browser, go to https://accounts.google.com/o/oauth2/auth?access_type=offline&approval_prompt=force&response_type=code&client_id=818368855108-8grd2eg9tj9f38os6f1urbcvsq399u8n.apps.googleusercontent.com&redirect_uri=http%3A%2F%2Flocalhost%3A62462&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email
Then click "Allow access".

Waiting for your authorization...
Authorization received, processing...
Successfully authorized.

Package "stats" already has version "0.0.4".
```

[![allow_access](/images/2013-01-27-using-dart-for-website-publishing-on-google-drive/allow_access.png)](/images/2013-01-27-using-dart-for-website-publishing-on-google-drive/allow_access.png) 

[![success.png](/images/2013-01-27-using-dart-for-website-publishing-on-google-drive/success.png)](/images/2013-01-27-using-dart-for-website-publishing-on-google-drive/success.png) 

After some initial slicing and dicing I was able to take what was needed from [pub][] and merge it into [dart-google-oauth2-library][] that [discovery_api_dart_client_generator][] depends on for OAuth2 support. [pub][] was structured such that all files are dart libraries, so ripping out parts was easy, I found the most issues with [http][] package. The client [requests][] `ContentType` could only be set as `application/x-www-form-urlencoded` when making requests, this did not seem to play nicely with Google APIs. Took many hours of debugging to figure out why `POST` method would fail but `GET` method would not. Stumbled on some Google mailing lists that mentioned some services do work with `ContentType` `application/x-www-form-urlencoded` and some only with `application/json`. So I created a separate client that does the `POST`, `PATCH`, `PUT`, `DELETE` methods required for the Google Client APIs.   

**Big thanks** to [Gerwin Sturm][] for working on this merge with me, in a very short amount of time we've been able to push the [dart-google-oauth2-library][] and [discovery_api_dart_client_generator][] into almost complete solutions for dart and Google Client API services. 

The [markdown.dart][] processor was for the most part a total freebie, [Bob Nystrom][] had already created a [markdown][] processor which eventually got rolled into [Dartdoc][]. All that was needed here is picking out the code from the dart repo, updating libraries and import, minor code clean up and hosting it on github.

One of my all time favorite Google APIs is the [url-shortener][] API. Even without OAuth2 you can use this service, now that we have patched up [dart-google-oauth2-library][] and [discovery_api_dart_client_generator][] shortening the long [webViewLink][] will be easy. A site note, [goo.gl][] links work great as for landing slides when giving a presentation, easy and short enough for audience to type into mobile phone, tablet or laptop to pull down your slides and follow along. 

Now we have all the parts needed to create a simple application that reads in some markdown, processes it to html, creates a website folder on drive, uploads the final html, then generates a shortened url. 

*We are still working on the best way to publish the Dart Google Client APIs, so please don't depend on the links below for too long, they will be out dated soon. This was just for testing.*

Starting off with our `pubspec.yaml` file we add the dependencies needed for the application. 

```yaml
name:  drive_publish_markdown
description:  Publishing markdown content to a public drive site
dependencies:
  urlshortener_v1_api:
    git: https://github.com/financeCoding/urlshortener_v1_api_client.git
  drive_v2_api:
    git: https://github.com/financeCoding/drive_v2_api_client.git
  markdown:
    git: https://github.com/financeCoding/markdown.dart.git
```

Getting a `identifier` and `secret` is simple, just goto your [Google APIs Console][] and pull out `Client ID` and `Client secret` for a `Client ID for installed applications` that was previously created. If you don't have one already they are easy to create.

* Goto API access in a project.  
[![api_access](/images/2013-01-27-using-dart-for-website-publishing-on-google-drive/api_access.png)](/images/2013-01-27-using-dart-for-website-publishing-on-google-drive/api_access.png) 

* Click Create another client ID. 
[![create_another_client_id](/images/2013-01-27-using-dart-for-website-publishing-on-google-drive/create_another_client_id.png)](/images/2013-01-27-using-dart-for-website-publishing-on-google-drive/create_another_client_id.png) 

* Choose Installed application and Installed type Other. Your Done!
[![create_client_id](/images/2013-01-27-using-dart-for-website-publishing-on-google-drive/create_client_id.png)](/images/2013-01-27-using-dart-for-website-publishing-on-google-drive/create_client_id.png) 

Apply `identifier` and `secret` to your code. 

```dart
import "dart:io";
import "dart:async";
import 'dart:crypto';
import "dart:json" as JSON;
import "package:google_oauth2_client/google_oauth2_console.dart";
import "package:drive_v2_api/drive_v2_api_console.dart" as drivelib;
import "package:urlshortener_v1_api/urlshortener_v1_api_console.dart" as urllib;
import "package:markdown/lib.dart" as markdown;

String identifier = "<IDENTIFIER>";
String secret = "<SECRET>";
List scopes = [drivelib.Drive.DRIVE_FILE_SCOPE, drivelib.Drive.DRIVE_SCOPE, urllib.Urlshortener.URLSHORTENER_SCOPE];
drivelib.Drive drive;
urllib.Urlshortener urlshort;
OAuth2Console auth;
```

Now with `identifier` and `secret` the setup for a dart application to use `Drive` and `Urlshortener` is easy, create a new `OAuth2Console` and pass them along to the constructor of `Drive` and `Urlshortener`. Note that the flag `makeAuthRequests` has been set on both objects, that allows us to make authroized calls on behalf of the user. You could create the Google Client API objects without a OAuth2 token and leave the `makeAuthRequests` as false, the objects would then only be allowed to access non-authenticated resources on the Google servers. 

```dart
void main() {
  /**
   * Create new or load existing oauth2 token.
   */
  auth = new OAuth2Console(identifier: identifier, secret: secret, scopes: scopes);

  /**
   * Create a new [drivelib.Drive] object with authenticated requests.
   */
  drive = new drivelib.Drive(auth);
  drive.makeAuthRequests = true;

  /**
   * Create a new [urllib.Urlshortener] object with authenticated requests.
   */
  urlshort = new urllib.Urlshortener(auth);
  urlshort.makeAuthRequests = true;

  /**
   * Create a new 'public_folder' and insert markdown as html
   */
  createPublicFolder("public_folder").then(processMarkdown);
}
```
I have to admit, updating permissions took me awhile to figure out. I first tried to update by calling `drive.files.update` with a modified `drivelib.File`. That was not the proper way to change permissions on [drive]. The correct way is to call the `drive.permissions.*` methods, lesson learned after some Googling and searching on [stackoverflow][] [drive-sdk][]. Setting the `Permissions` and `mimeType` are the most important parts to note here, thats what change the folder into a public website hosted on drive viewable to anyone.   

```dart
void insertPermissions(drivelib.File file, Completer completer) {
  /**
   * Create new [drivelib.Permission] for insertion to the
   * drive permissions list. This will mark the folder publicly
   * readable by anyone.
   */
  var permissions = new drivelib.Permission.fromJson({
    "value": "",
    "type": "anyone",
    "role": "reader"
  });

  drive.permissions.insert(permissions, file.id).then((drivelib.Permission permission) => completer.complete(file));
}

Future<drivelib.File> createPublicFolder(String folderName) {
  var completer = new Completer();

  /**
   * Create the [drivelib.File] with a web folder app mime type.
   */
  drivelib.File file = new drivelib.File.fromJson({
    'title': folderName,
    'mimeType': "application/vnd.google-apps.folder"
  });

  /**
   * Insert the [drivelib.File] to google drive.
   */
  drive.files.insert(file).then((drivelib.File newfile) => insertPermissions(newfile, completer));

  return completer.future;
}
```

Now we get to the meat and potatoes of our application. At this point we have a public web folder that can host our content. We do the follow steps

* Read in the markdown and html template file 
* Replace a tag in the template with the markdown 
* Insert the file into drive 
* Add a parent reference to the file 
* Get the url to the folder
* Shorten the url 

```dart
processMarkdown(drivelib.File folder) {
  /**
   * Read in both markdown and html template
   */
  var markdownFile = new File('markdown.md');
  var templateFile = new File('template.html');
  var markdownStr = markdownFile.readAsStringSync();
  var templateStr = templateFile.readAsStringSync();

  /**
   * Convert markdown to html.
   */
  var page = markdown.markdownToHtml(markdownStr);

  /**
   * Replace $page with converted markdown.
   */
  templateStr = templateStr.replaceFirst('\$page', page);

  /**
   * Create a new [drivelib.File] to hold the html content.
   */
  drivelib.File file = new drivelib.File.fromJson({
    'title': 'index.html',
    'mimeType': "text/html"
  });

  /**
   * Create a new [drivelib.ParentReference] to link the html file to.
   */
  drivelib.ParentReference newParent = new drivelib.ParentReference.fromJson({'id': folder.id});

  /**
   * Encode the content to Base64 for inserting into drive.
   */
  var content = CryptoUtils.bytesToBase64(templateStr.charCodes);

  /**
   * 1) Insert the new file with title index.html and type text/html
   * 2) Insert the new parent of the file (i.e. place the file in the folder)
   * 3) Get the folders web view link
   * 4) Shorten the web view link with UrlShortener
   */
  drive.files.insert(file, content: content).then((drivelib.File insertedFile) {
    drive.parents.insert(newParent, insertedFile.id).then((drivelib.ParentReference parentReference) {
      drive.files.get(folder.id).then((folder) {
        print("Web View Link: ${folder.webViewLink}");
        var url = new urllib.Url.fromJson({'longUrl': folder.webViewLink});
        urlshort.url.insert(url).then((url) {
          print("Short Url ${url.id}");
        });
      });
    });
  });
}
```

The code for this sample can be found on [github][] [drive_publish_markdown][]. Executing the sample follows the flow explained above 

* Ask user to generate token 
* Get token from redirect 
* Store token 
* Make [drive] and [url-shortener] requests. 

```
13:32:40-adam@Adams-MacBook-Air:~/dart/drive_publish_markdown/bin
$ dart drive_publish_markdown.dart 
Client needs your authorization for scopes [https://www.googleapis.com/auth/drive.file, https://www.googleapis.com/auth/drive, https://www.googleapis.com/auth/urlshortener]
In a web browser, go to https://accounts.google.com/o/oauth2/auth?access_type=offline&approval_prompt=force&response_type=code&client_id=299615367852-n0kfup30mfj5emlclfgud9g76itapvk9.apps.googleusercontent.com&redirect_uri=http%3A%2F%2Flocalhost%3A62900&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fdrive.file+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fdrive+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Furlshortener
Then click "Allow access".

Waiting for your authorization...
Authorization received, processing...
Calling curl with --insecure, ca-certificates.crt not found.
Successfully authorized.

Calling curl with --insecure, ca-certificates.crt not found.
Web View Link: https://www.googledrive.com/host/0B29MR2FlgtejWnh6SS03LWFnVE0/
Short Url http://goo.gl/3fGi3
```

[![allow_access_drive_publish_markdown](/images/2013-01-27-using-dart-for-website-publishing-on-google-drive/allow_access_drive_publish_markdown.png)](/images/2013-01-27-using-dart-for-website-publishing-on-google-drive/allow_access_drive_publish_markdown.png) 

[![generated_markdown_published_on_drive](/images/2013-01-27-using-dart-for-website-publishing-on-google-drive/generated_markdown_published_on_drive.png)](/images/2013-01-27-using-dart-for-website-publishing-on-google-drive/generated_markdown_published_on_drive.png) 

Thats all, have fun with this really simple and easy to get started sample. 

[github]: http://github.com
[drive]: https://developers.google.com/drive/
[drive_publish_markdown]: https://github.com/financeCoding/drive_publish_markdown
[stackoverflow]: http://stackoverflow.com/
[drive-sdk]: http://stackoverflow.com/questions/tagged/google-drive-sdk
[Google APIs Console]: https://code.google.com/apis/console
[webViewLink]: https://developers.google.com/drive/v2/reference/files
[url-shortener]: https://developers.google.com/url-shortener/
[goo.gl]: http://goo.gl
[requests]: https://github.com/dart-lang/bleeding_edge/blob/master/dart/pkg/http/lib/src/request.dart#L119
[http]: http://pub.dartlang.org/packages/http
[Dartdoc]: https://github.com/dart-lang/bleeding_edge/tree/master/dart/sdk/lib/_internal/dartdoc
[Bob Nystrom]: https://plus.google.com/100798142896685420545
[markdown]: https://github.com/dart-lang/bleeding_edge/tree/master/dart/samples/markdown
[markdown.dart]: https://github.com/financeCoding/markdown.dart
[dart-google-oauth2-library]: https://github.com/dart-gde/dart-google-oauth2-library
[discovery_api_dart_client_generator]: https://github.com/dart-gde/discovery_api_dart_client_generator
[Gerwin Sturm]: https://profiles.google.com/scarygami
[pub]: http://pub.dartlang.org/