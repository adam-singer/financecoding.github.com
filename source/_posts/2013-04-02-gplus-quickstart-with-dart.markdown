---
layout: post
title: "gplus quickstart with dart"
date: 2013-04-02 19:25
comments: true
categories: 
- Dart
- Google
- API
- gplus
---

Tonights mash-up was taking the [gplus-quickstart-dart][] and wiring it up for server side support. Similar to the [gplus-quickstart-java][], the client will use the [gplus login button][] to do the [OAuth2WebServer][] flow and send the code over to the server. The server can then verify and make calls on behalf of the client since an 'offline' token was requested. This demo just features the server side and what was used to put it together. [Yulian Kuncheff][] has been the primary developer behind [fukiya][] which is an express like framework for dart. The thing I liked most about [fukiya][] was how simple and easy it was to setup URL handlers. 

First off, setting up some dependencies. 

```
dependencies:
  google_plus_v1_api: any
  browser: any
  fukiya: '>=0.0.11'
  html5lib: ">=0.4.1 <0.4.2"
  logging: ">=0.4.3+5"
```

A quick outline of what URLs fukiya handles. Dead simple to setup!

```dart 
void main() {
  new Fukiya()
  ..get('/', getIndexHandler)
  ..get('/index.html', getIndexHandler)
  ..get('/index', getIndexHandler)
  ..post('/connect', postConnectDataHandler)
  ..get('/people', getPeopleHandler)
  ..post('/disconnect', postDisconnectHandler)
  ..staticFiles('./web')
  ..use(new FukiyaJsonParser())
  ..listen('127.0.0.1', 3333);
}
```

The index handler is special cause we needed to inject a state token into the page and HTTP session. The state token is then verified on the `/connect` post. The one-time token helps avoid any [Confused_deputy_problem][]s.

```dart
void getIndexHandler(FukiyaContext context) {
  // Create a state token. 
  context.request.session["state_token"] = _createStateToken();
  
  // Readin the index file and add state token into the meta element. 
  var file = new File(INDEX_HTML);
  file.exists().then((bool exists) {
    if (exists) {
      file.readAsString().then((String indexDocument) {
        Document doc = new Document.html(indexDocument);
        Element metaState = new Element.html('<meta name="state_token" content="${context.request.session["state_token"]}">');
        doc.head.children.add(metaState);
        context.response.writeBytes(doc.outerHtml.codeUnits);
        context.response.done.catchError((e) => serverLogger.fine("File Response error: ${e}"));
        context.response.close();
      }, onError: (error) => serverLogger.fine("error = $error"));
    } else {
      context.response.statusCode = 404;
      context.response.close();
    }
  });
}
```

On the `/connect` post we will expect a gplus id to be passed to the query parameters and some token data posted. We can then verify the state token and use the token data for accessing the Google APIs.

```dart
void postConnectDataHandler(FukiyaContext context) {
  serverLogger.fine("postConnectDataHandler");
  String tokenData = context.request.session.containsKey("access_token") ? context.request.session["access_token"] : null; // TODO: handle missing token
  String stateToken = context.request.session.containsKey("state_token") ? context.request.session["state_token"] : null;
  String queryStateToken = context.request.queryParameters.containsKey("state_token") ? context.request.queryParameters["state_token"] : null;
  
  // Check if the token already exists for this session. 
  if (tokenData != null) {
    context.send("Current user is already connected.");
    return;
  }
  
  // Check if any of the needed token values are null or mismatched.
  if (stateToken == null || queryStateToken == null || stateToken != queryStateToken) {
    context.response.statusCode = 401;
    context.send("Invalid state parameter."); 
    return;
  }
  
  // Normally the state would be a one-time use token, however in our
  // simple case, we want a user to be able to connect and disconnect
  // without reloading the page.  Thus, for demonstration, we don't
  // implement this best practice.
  context.request.session.remove("state_token");
  
  String gPlusId = context.request.queryParameters["gplus_id"];
  StringBuffer sb = new StringBuffer();
  // Read data from request.
  context.request
  .transform(new StringDecoder())
  .listen((data) => sb.write(data), onDone: () {
    serverLogger.fine("context.request.listen.onDone = ${sb.toString()}");
    Map requestData = JSON.parse(sb.toString());
    
    Map fields = {
              "grant_type": "authorization_code",
              "code": requestData["code"],
              // http://www.riskcompletefailure.com/2013/03/postmessage-oauth-20.html
              "redirect_uri": "postmessage",
              "client_id": CLIENT_ID,
              "client_secret": CLIENT_SECRET
    };

    http.Client _httpClient = new http.Client();
    _httpClient.post(TOKEN_ENDPOINT, fields: fields).then((http.Response response) {
      // At this point we have the token and refresh token.
      var credentials = JSON.parse(response.body);
      _httpClient.close();
      
      var verifyTokenUrl = '${TOKENINFO_URL}?access_token=${credentials["access_token"]}';
      new http.Client()
      ..get(verifyTokenUrl).then((http.Response response)  {
        serverLogger.fine("response = ${response.body}");
        
        var verifyResponse = JSON.parse(response.body);
        String userId = verifyResponse.containsKey("user_id") ? verifyResponse["user_id"] : null;
        String accessToken = credentials.containsKey("access_token") ? credentials["access_token"] : null;
        if (userId != null && userId == gPlusId && accessToken != null) {
          context.request.session["access_token"] = accessToken;
          context.send("POST OK");
        } else {
          context.response.statusCode = 401;
          context.send("POST FAILED ${userId} != ${gPlusId}"); 
        }
      });
    });
  });
}
```

Now the HTTP session has the full ability to make calls on behalf of the user. The `/people` method will be called from the client to retrieve the list of visible friends of that user. 

```dart
void getPeopleHandler(FukiyaContext context) {
  String accessToken = context.request.session.containsKey("access_token") ? context.request.session["access_token"] : null;
  SimpleOAuth2 simpleOAuth2 = new SimpleOAuth2()..credentials = new console_auth.Credentials(accessToken);
  plus.Plus plusclient = new plus.Plus(simpleOAuth2);
  plusclient.makeAuthRequests = true;
  plusclient.people.list("me", "visible").then((plus.PeopleFeed people) {
    serverLogger.fine("/people = $people");
    context.send(people.toString());
  });
}
``` 

The final responsibility we can bestow upon the server is allowing the client to disconnect by revoking OAuth access.

```dart
void postDisconnectHandler(FukiyaContext context) {
  String tokenData = context.request.session.containsKey("access_token") ? context.request.session["access_token"] : null;
  if (tokenData == null) {
    context.response.statusCode = 401;
    context.send("Current user not connected.");
    return;
  }
  
  final String revokeTokenUrl = "${TOKEN_REVOKE_ENDPOINT}?token=${tokenData}";
  context.request.session.remove("access_token");
  
  new http.Client()..get(revokeTokenUrl).then((http.Response response) {
    context.request.session["state_token"] = _createStateToken();
    Map data = {
                "state_token": context.request.session["state_token"],
                "message" : "Successfully disconnected."
                };
    context.send(JSON.stringify(data));
  });
}
``` 

Thats about it, Happy Dart Hacking! Special thanks to [Gerwin Sturm][] for putting together the original example for client side. Full source code can be found at [gplus-quickstart-dart][] in the server folder. Please replace your own keys cause mine will be removed at some point. 

[Gerwin Sturm]: https://plus.google.com/112336147904981294875
[gplus-quickstart-dart]: https://github.com/Scarygami/gplus-quickstart-dart
[gplus-quickstart-java]: https://github.com/googleplus/gplus-quickstart-java
[java quickstart guide]: https://developers.google.com/+/quickstart/java
[gplus login button]: https://developers.google.com/+/web/+1button/
[OAuth2WebServer]: https://developers.google.com/accounts/docs/OAuth2WebServer
[Yulian Kuncheff]: https://plus.google.com/u/0/109130932502535286138/
[fukiya]: https://github.com/Daegalus/fukiya
[Confused_deputy_problem]: http://en.wikipedia.org/wiki/Confused_deputy_problem