# couchbase_lite_example

Demonstrates how to use the couchbase_lite plugin.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

## Local Server Setup

Download and setup Couchbase Server / Sync Gateway Community Editions on your local machine the following link
- [Sync Gatway Getting Started](https://docs.couchbase.com/sync-gateway/current/getting-started.html)
- [Couchbase Downloads](https://www.couchbase.com/downloads)

Setup beer-sample database [Local Couchbase Server](http://127.0.0.1:8091/):

- Add the beer-sample bucket: Settings > Sample Buckets
- Create a sync_gateway user in the Couchbase Server under Security
- Give sync_gateway access to the beer-sample

Start Sync Gateway:

~/Downloads/couchbase-sync-gateway/bin/sync_gateway ~/path/to/sync-gateway-config.json

*Note*: Included in this example is sync-gateway-config.json (Login credentials u: foo / p: bar)

As of Android Pie, version 9, API 28, cleartext support is disabled, by default. Although wss: protocol URLs are not affected, in order to use the ws: protocol, applications must target API 27 or lower, or must configure application network security as described [here](https://developer.android.com/training/articles/security-config#CleartextTrafficPermitted).

```xml
<application android:usesCleartextTraffic="true">
</application>
```