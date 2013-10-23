---
layout: post
title: "google client apis new release 0.4.x"
date: 2013-10-22 19:34
comments: true
categories: 
- Dart
- GoogleAPI
- Client
- Pub
---

The [dart-gde](https://github.com/dart-gde?tab=members) team has updated the [google client apis](https://github.com/dart-google-apis) to `'>=0.4.0'`. Along with this change was an update for [Google OAuth2 Client](http://pub.dartlang.org/packages/google_oauth2_client) to `'>=0.3.0'`.

## The breaking changes for [Google OAuth2 Client](http://pub.dartlang.org/packages/google_oauth2_client)

* SystemCache has been removed.
* `GoogleOAuth2.ensureAuthenticated()` A much cleaner impl that eliminates the need to pass in a HttpRequest object to authenticate.
* All dependencies bumped to latest versions.
* Code refactored.
* Dead code eliminated.  
* Remove deprecated libraries.
* Heavy logging removed.

## The breaking changes for generated [google client apis](https://github.com/dart-google-apis) include

* Renamed `lib/src/{cloud_api.dart -> client_base.dart}` `lib/src/{cloud_api_console.dart -> console_client.dart}` `lib/src/{cloud_api_browser.dart -> browser_client.dart}`.
* `ClientBase.responseParse(int statusCode, String responseBody)` introduced and handles parsing `responseBody`. `responseParse` will throw `DetailedApiRequestError` if the body has an error. 
* Renamed `APIRequestException` -> `APIRequestError`.
* Remove deprecated libraries.

## Updating requires a small change in `pubspec.yaml`

```yaml pubspec.yaml
dependencies:
  google_plus_v1_api: '>=0.4.0'
``` 

A small collection of demo examples could be found at [dart_api_client_examples](https://github.com/dart-gde/dart_api_client_examples).

## Full list of available Google client apis on [pub.dartlang.org](http://pub.dartlang.org)

* [dart_adexchangebuyer_v1_api_client](http://pub.dartlang.org/packages/dart_adexchangebuyer_v1_api_client)
* [dart_adexchangebuyer_v1_1_api_client](http://pub.dartlang.org/packages/dart_adexchangebuyer_v1_1_api_client)
* [dart_adexchangebuyer_v1_2_api_client](http://pub.dartlang.org/packages/dart_adexchangebuyer_v1_2_api_client)
* [dart_adexchangebuyer_v1_3_api_client](http://pub.dartlang.org/packages/dart_adexchangebuyer_v1_3_api_client)
* [dart_adexchangeseller_v1_api_client](http://pub.dartlang.org/packages/dart_adexchangeseller_v1_api_client)
* [dart_adexchangeseller_v1_1_api_client](http://pub.dartlang.org/packages/dart_adexchangeseller_v1_1_api_client)
* [dart_admin_directory_v1_api_client](http://pub.dartlang.org/packages/dart_admin_directory_v1_api_client)
* [dart_admin_email_migration_v2_api_client](http://pub.dartlang.org/packages/dart_admin_email_migration_v2_api_client)
* [dart_admin_reports_v1_api_client](http://pub.dartlang.org/packages/dart_admin_reports_v1_api_client)
* [dart_adsense_v1_2_api_client](http://pub.dartlang.org/packages/dart_adsense_v1_2_api_client)
* [dart_adsense_v1_3_api_client](http://pub.dartlang.org/packages/dart_adsense_v1_3_api_client)
* [dart_adsensehost_v4_1_api_client](http://pub.dartlang.org/packages/dart_adsensehost_v4_1_api_client)
* [dart_analytics_v2_4_api_client](http://pub.dartlang.org/packages/dart_analytics_v2_4_api_client)
* [dart_analytics_v3_api_client](http://pub.dartlang.org/packages/dart_analytics_v3_api_client)
* [dart_androidpublisher_v1_api_client](http://pub.dartlang.org/packages/dart_androidpublisher_v1_api_client)
* [dart_androidpublisher_v1_1_api_client](http://pub.dartlang.org/packages/dart_androidpublisher_v1_1_api_client)
* [dart_appstate_v1_api_client](http://pub.dartlang.org/packages/dart_appstate_v1_api_client)
* [dart_audit_v1_api_client](http://pub.dartlang.org/packages/dart_audit_v1_api_client)
* [dart_bigquery_v2_api_client](http://pub.dartlang.org/packages/dart_bigquery_v2_api_client)
* [dart_blogger_v2_api_client](http://pub.dartlang.org/packages/dart_blogger_v2_api_client)
* [dart_blogger_v3_api_client](http://pub.dartlang.org/packages/dart_blogger_v3_api_client)
* [dart_books_v1_api_client](http://pub.dartlang.org/packages/dart_books_v1_api_client)
* [dart_calendar_v3_api_client](http://pub.dartlang.org/packages/dart_calendar_v3_api_client)
* [dart_civicinfo_us_v1_api_client](http://pub.dartlang.org/packages/dart_civicinfo_us_v1_api_client)
* [dart_compute_v1beta15_api_client](http://pub.dartlang.org/packages/dart_compute_v1beta15_api_client)
* [dart_compute_v1beta16_api_client](http://pub.dartlang.org/packages/dart_compute_v1beta16_api_client)
* [dart_coordinate_v1_api_client](http://pub.dartlang.org/packages/dart_coordinate_v1_api_client)
* [dart_customsearch_v1_api_client](http://pub.dartlang.org/packages/dart_customsearch_v1_api_client)
* [dart_datastore_v1beta1_api_client](http://pub.dartlang.org/packages/dart_datastore_v1beta1_api_client)
* [dart_datastore_v1beta2_api_client](http://pub.dartlang.org/packages/dart_datastore_v1beta2_api_client)
* [dart_dfareporting_v1_api_client](http://pub.dartlang.org/packages/dart_dfareporting_v1_api_client)
* [dart_dfareporting_v1_1_api_client](http://pub.dartlang.org/packages/dart_dfareporting_v1_1_api_client)
* [dart_dfareporting_v1_2_api_client](http://pub.dartlang.org/packages/dart_dfareporting_v1_2_api_client)
* [dart_dfareporting_v1_3_api_client](http://pub.dartlang.org/packages/dart_dfareporting_v1_3_api_client)
* [dart_discovery_v1_api_client](http://pub.dartlang.org/packages/dart_discovery_v1_api_client)
* [dart_doubleclickbidmanager_v1_api_client](http://pub.dartlang.org/packages/dart_doubleclickbidmanager_v1_api_client)
* [dart_doubleclicksearch_v2_api_client](http://pub.dartlang.org/packages/dart_doubleclicksearch_v2_api_client)
* [dart_drive_v1_api_client](http://pub.dartlang.org/packages/dart_drive_v1_api_client)
* [dart_drive_v2_api_client](http://pub.dartlang.org/packages/dart_drive_v2_api_client)
* [dart_freebase_v1_sandbox_api_client](http://pub.dartlang.org/packages/dart_freebase_v1_sandbox_api_client)
* [dart_freebase_v1sandbox_api_client](http://pub.dartlang.org/packages/dart_freebase_v1sandbox_api_client)
* [dart_freebase_v1_api_client](http://pub.dartlang.org/packages/dart_freebase_v1_api_client)
* [dart_fusiontables_v1_api_client](http://pub.dartlang.org/packages/dart_fusiontables_v1_api_client)
* [dart_games_v1_api_client](http://pub.dartlang.org/packages/dart_games_v1_api_client)
* [dart_gamesmanagement_v1management_api_client](http://pub.dartlang.org/packages/dart_gamesmanagement_v1management_api_client)
* [dart_gan_v1beta1_api_client](http://pub.dartlang.org/packages/dart_gan_v1beta1_api_client)
* [dart_groupsmigration_v1_api_client](http://pub.dartlang.org/packages/dart_groupsmigration_v1_api_client)
* [dart_groupssettings_v1_api_client](http://pub.dartlang.org/packages/dart_groupssettings_v1_api_client)
* [dart_identitytoolkit_v3_api_client](http://pub.dartlang.org/packages/dart_identitytoolkit_v3_api_client)
* [dart_licensing_v1_api_client](http://pub.dartlang.org/packages/dart_licensing_v1_api_client)
* [dart_mirror_v1_api_client](http://pub.dartlang.org/packages/dart_mirror_v1_api_client)
* [dart_oauth2_v1_api_client](http://pub.dartlang.org/packages/dart_oauth2_v1_api_client)
* [dart_oauth2_v2_api_client](http://pub.dartlang.org/packages/dart_oauth2_v2_api_client)
* [dart_orkut_v2_api_client](http://pub.dartlang.org/packages/dart_orkut_v2_api_client)
* [dart_pagespeedonline_v1_api_client](http://pub.dartlang.org/packages/dart_pagespeedonline_v1_api_client)
* [dart_plus_v1_api_client](http://pub.dartlang.org/packages/dart_plus_v1_api_client)
* [dart_plusdomains_v1_api_client](http://pub.dartlang.org/packages/dart_plusdomains_v1_api_client)
* [dart_prediction_v1_2_api_client](http://pub.dartlang.org/packages/dart_prediction_v1_2_api_client)
* [dart_prediction_v1_3_api_client](http://pub.dartlang.org/packages/dart_prediction_v1_3_api_client)
* [dart_prediction_v1_4_api_client](http://pub.dartlang.org/packages/dart_prediction_v1_4_api_client)
* [dart_prediction_v1_5_api_client](http://pub.dartlang.org/packages/dart_prediction_v1_5_api_client)
* [dart_prediction_v1_6_api_client](http://pub.dartlang.org/packages/dart_prediction_v1_6_api_client)
* [dart_reseller_v1sandbox_api_client](http://pub.dartlang.org/packages/dart_reseller_v1sandbox_api_client)
* [dart_reseller_v1_api_client](http://pub.dartlang.org/packages/dart_reseller_v1_api_client)
* [dart_shopping_v1_api_client](http://pub.dartlang.org/packages/dart_shopping_v1_api_client)
* [dart_siteverification_v1_api_client](http://pub.dartlang.org/packages/dart_siteverification_v1_api_client)
* [dart_sqladmin_v1beta1_api_client](http://pub.dartlang.org/packages/dart_sqladmin_v1beta1_api_client)
* [dart_storage_v1beta1_api_client](http://pub.dartlang.org/packages/dart_storage_v1beta1_api_client)
* [dart_storage_v1beta2_api_client](http://pub.dartlang.org/packages/dart_storage_v1beta2_api_client)
* [dart_taskqueue_v1beta1_api_client](http://pub.dartlang.org/packages/dart_taskqueue_v1beta1_api_client)
* [dart_taskqueue_v1beta2_api_client](http://pub.dartlang.org/packages/dart_taskqueue_v1beta2_api_client)
* [dart_tasks_v1_api_client](http://pub.dartlang.org/packages/dart_tasks_v1_api_client)
* [dart_translate_v2_api_client](http://pub.dartlang.org/packages/dart_translate_v2_api_client)
* [dart_urlshortener_v1_api_client](http://pub.dartlang.org/packages/dart_urlshortener_v1_api_client)
* [dart_webfonts_v1_api_client](http://pub.dartlang.org/packages/dart_webfonts_v1_api_client)
* [dart_youtube_v3_api_client](http://pub.dartlang.org/packages/dart_youtube_v3_api_client)
* [dart_youtubeanalytics_v1_api_client](http://pub.dartlang.org/packages/dart_youtubeanalytics_v1_api_client)
* [dart_youtubeanalytics_v1beta1_api_client](http://pub.dartlang.org/packages/dart_youtubeanalytics_v1beta1_api_client)