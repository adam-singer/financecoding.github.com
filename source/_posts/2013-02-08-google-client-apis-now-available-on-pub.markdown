---
layout: post
title: "Dart Google Client Apis Now Available On Pub"
date: 2013-02-08 14:18
comments: true
categories: 
- Dart
- GoogleAPI
- Client
- Pub
---

The [dart-gde](https://github.com/dart-gde?tab=members) team now brings you not only a generator to create google client apis but also [pub.dartlang.org](http://pub.dartlang.org) hosted packages. Lot of thanks goes to [Gerwin Sturm](https://profiles.google.com/scarygami) for all of his hard work over the last few weeks developing [discovery_api_dart_client_generator](https://github.com/dart-gde/discovery_api_dart_client_generator) and [dart-google-oauth2-library](https://github.com/dart-gde/dart-google-oauth2-library).

We plan to keep the client libraries up to date with [uploader.dart](https://github.com/dart-gde/discovery_api_dart_client_generator/blob/master/tool/update.dart) script. Still somewhat a manual process, future automation could happen when/if we have the ability to get notified about google api changes. For now we will push updates when appropriate. This will ensure that we can push the latest versions of the apis to pub and still have previous revisions available. Some of the more intricate parts of this script include auto version incrementing pubspec files and syncing to github, then pushing to pub. 

Would you want to contribute to this project? Please feel free to ping us [Adam Singer](https://profiles.google.com/financeCoding)/[Gerwin Sturm](https://profiles.google.com/scarygami) on [g+](https://plus.google.com), we're definitely looking to refactor some parts and test others. Our main focus for this release was to get something out the door that is pleasantly usable. 

Many hours of testing and development was done to have a simple and easy way to use the google client apis in dart! We hope you enjoy and look forward to seeing what you build. 
To get started with client api examples check out [dart_api_client_examples](https://github.com/dart-gde/dart_api_client_examples). The [github](http://www.github.com) hosted source code can be found at [dart-google-apis](https://github.com/dart-google-apis)

### Full list of available Google client apis on [pub.dartlang.org](http://pub.dartlang.org)

 * [google_adexchangebuyer_v1_api](http://pub.dartlang.org/packages/google_adexchangebuyer_v1_api)
 * [google_adexchangebuyer_v1_1_api](http://pub.dartlang.org/packages/google_adexchangebuyer_v1_1_api)
 * [google_adexchangeseller_v1_api](http://pub.dartlang.org/packages/google_adexchangeseller_v1_api)
 * [google_adsense_v1_api](http://pub.dartlang.org/packages/google_adsense_v1_api)
 * [google_adsense_v1_1_api](http://pub.dartlang.org/packages/google_adsense_v1_1_api)
 * [google_adsense_v1_2_api](http://pub.dartlang.org/packages/google_adsense_v1_2_api)
 * [google_adsensehost_v4_1_api](http://pub.dartlang.org/packages/google_adsensehost_v4_1_api)
 * [google_analytics_v2_4_api](http://pub.dartlang.org/packages/google_analytics_v2_4_api)
 * [google_analytics_v3_api](http://pub.dartlang.org/packages/google_analytics_v3_api)
 * [google_androidpublisher_v1_api](http://pub.dartlang.org/packages/google_androidpublisher_v1_api)
 * [google_audit_v1_api](http://pub.dartlang.org/packages/google_audit_v1_api)
 * [google_bigquery_v2_api](http://pub.dartlang.org/packages/google_bigquery_v2_api)
 * [google_blogger_v2_api](http://pub.dartlang.org/packages/google_blogger_v2_api)
 * [google_blogger_v3_api](http://pub.dartlang.org/packages/google_blogger_v3_api)
 * [google_books_v1_api](http://pub.dartlang.org/packages/google_books_v1_api)
 * [google_calendar_v3_api](http://pub.dartlang.org/packages/google_calendar_v3_api)
 * [google_civicinfo_us_v1_api](http://pub.dartlang.org/packages/google_civicinfo_us_v1_api)
 * [google_compute_v1beta12_api](http://pub.dartlang.org/packages/google_compute_v1beta12_api)
 * [google_compute_v1beta13_api](http://pub.dartlang.org/packages/google_compute_v1beta13_api)
 * [google_compute_v1beta14_api](http://pub.dartlang.org/packages/google_compute_v1beta14_api)
 * [google_coordinate_v1_api](http://pub.dartlang.org/packages/google_coordinate_v1_api)
 * [google_customsearch_v1_api](http://pub.dartlang.org/packages/google_customsearch_v1_api)
 * [google_dfareporting_v1_api](http://pub.dartlang.org/packages/google_dfareporting_v1_api)
 * [google_dfareporting_v1_1_api](http://pub.dartlang.org/packages/google_dfareporting_v1_1_api)
 * [google_discovery_v1_api](http://pub.dartlang.org/packages/google_discovery_v1_api)
 * [google_drive_v1_api](http://pub.dartlang.org/packages/google_drive_v1_api)
 * [google_drive_v2_api](http://pub.dartlang.org/packages/google_drive_v2_api)
 * [google_freebase_v1sandbox_api](http://pub.dartlang.org/packages/google_freebase_v1sandbox_api)
 * [google_freebase_v1_api](http://pub.dartlang.org/packages/google_freebase_v1_api)
 * [google_fusiontables_v1_api](http://pub.dartlang.org/packages/google_fusiontables_v1_api)
 * [google_gan_v1beta1_api](http://pub.dartlang.org/packages/google_gan_v1beta1_api)
 * [google_groupsmigration_v1_api](http://pub.dartlang.org/packages/google_groupsmigration_v1_api)
 * [google_groupssettings_v1_api](http://pub.dartlang.org/packages/google_groupssettings_v1_api)
 * [google_latitude_v1_api](http://pub.dartlang.org/packages/google_latitude_v1_api)
 * [google_licensing_v1_api](http://pub.dartlang.org/packages/google_licensing_v1_api)
 * [google_oauth2_v1_api](http://pub.dartlang.org/packages/google_oauth2_v1_api)
 * [google_oauth2_v2_api](http://pub.dartlang.org/packages/google_oauth2_v2_api)
 * [google_orkut_v2_api](http://pub.dartlang.org/packages/google_orkut_v2_api)
 * [google_pagespeedonline_v1_api](http://pub.dartlang.org/packages/google_pagespeedonline_v1_api)
 * [google_plus_v1moments_api](http://pub.dartlang.org/packages/google_plus_v1moments_api)
 * [google_plus_v1_api](http://pub.dartlang.org/packages/google_plus_v1_api)
 * [google_prediction_v1_2_api](http://pub.dartlang.org/packages/google_prediction_v1_2_api)
 * [google_prediction_v1_3_api](http://pub.dartlang.org/packages/google_prediction_v1_3_api)
 * [google_prediction_v1_4_api](http://pub.dartlang.org/packages/google_prediction_v1_4_api)
 * [google_prediction_v1_5_api](http://pub.dartlang.org/packages/google_prediction_v1_5_api)
 * [google_reseller_v1sandbox_api](http://pub.dartlang.org/packages/google_reseller_v1sandbox_api)
 * [google_reseller_v1_api](http://pub.dartlang.org/packages/google_reseller_v1_api)
 * [google_shopping_v1_api](http://pub.dartlang.org/packages/google_shopping_v1_api)
 * [google_siteverification_v1_api](http://pub.dartlang.org/packages/google_siteverification_v1_api)
 * [google_storage_v1beta1_api](http://pub.dartlang.org/packages/google_storage_v1beta1_api)
 * [google_taskqueue_v1beta1_api](http://pub.dartlang.org/packages/google_taskqueue_v1beta1_api)
 * [google_taskqueue_v1beta2_api](http://pub.dartlang.org/packages/google_taskqueue_v1beta2_api)
 * [google_tasks_v1_api](http://pub.dartlang.org/packages/google_tasks_v1_api)
 * [google_translate_v2_api](http://pub.dartlang.org/packages/google_translate_v2_api)
 * [google_urlshortener_v1_api](http://pub.dartlang.org/packages/google_urlshortener_v1_api)
 * [google_webfonts_v1_api](http://pub.dartlang.org/packages/google_webfonts_v1_api)
 * [google_youtube_v3_api](http://pub.dartlang.org/packages/google_youtube_v3_api)
 * [google_youtubeanalytics_v1_api](http://pub.dartlang.org/packages/google_youtubeanalytics_v1_api)
 * [google_youtubeanalytics_v1beta1_api](http://pub.dartlang.org/packages/google_youtubeanalytics_v1beta1_api)

