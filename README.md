# couchbase_lite plugin
[![Build Status](https://travis-ci.org/SaltechSystems/couchbase_lite.svg?branch=master)](https://travis-ci.org/SaltechSystems/couchbase_lite)
[![Coverage Status](https://coveralls.io/repos/github/SaltechSystems/couchbase_lite/badge.svg?branch=master)](https://coveralls.io/github/SaltechSystems/couchbase_lite?branch=master)
[![pub package](https://img.shields.io/pub/v/couchbase_lite.svg)](https://pub.dartlang.org/packages/couchbase_lite)

A Flutter plugin for Couchbase Lite Community Edition. An embedded lightweight, noSQL database with live synchronization and offline support on Android and iOS.

The goal of this project is to align this library with the [Swift SDK API](https://docs.couchbase.com/mobile/2.5.0/couchbase-lite-swift/) for Couchbase Lite.

*Note*: This plugin is still under development, and some APIs might not be available yet.
[Feedback](https://github.com/SaltechSystems/couchbase_lite/issues) and [Pull Requests](https://github.com/SaltechSystems/couchbase_lite/pulls) are most welcome!

This project forked from [Fluttercouch](https://github.com/oltrenuovefrontiere/fluttercouch)

## Getting Started

In your flutter project add the dependency:

```yaml
dependencies:
  couchbase_lite: ^2.7.0
  
  flutter:
      sdk: flutter
```

For help getting started with Flutter, view the 
[online documentation](https://flutter.dev/docs)

## Supported Versions

### iOS

| Platform | Minimum OS version |
| -------- | ------------------ |
| iOS      | 9.0                |

### Android

| Platform | Runtime architectures | Minimum API Level |
| -------- | --------------------- | ----------------- |
| Android  | armeabi-v7a           | 19                |
| Android  | arm64-v8a             | 21                |
| Android  | x86                   | 19                |

## API References

[Swift SDK API References](https://docs.couchbase.com/mobile/2.7.0/couchbase-lite-swift/)

[Java SDK API References](http://docs.couchbase.com/mobile/2.7.0/couchbase-lite-java)

*Note*: Syntax follows the Swift SDK but these are the SDKs used for the platform code.

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

*Note*: Included in this example is sync-gateway-config.json (Login => u: foo, p: bar)


## Usage example

*Note*: The protocol ws and not wss is used in the example. The easy way to implement this is to use this attribute to your AndroidManifest.xml where you allow all http for all requests:

```xml
<application android:usesCleartextTraffic="true">
</application>
```

Below is an example for the database using the BLoC pattern ( View <-> BLoC <-> Repository <-> Database )

```dart
class AppDatabase {
  AppDatabase._internal();

  static final AppDatabase instance = AppDatabase._internal();

  String dbName = "myDatabase";
  List<Future> pendingListeners = List();
  ListenerToken _replicatorListenerToken;
  Database database;
  Replicator replicator;

  Future<bool> login(String username, String password) async {
    try {
      database = await Database.initWithName(dbName);
      // Note wss://10.0.2.2:4984/my-database is for the android simulator on your local machine's couchbase database
      ReplicatorConfiguration config =
          ReplicatorConfiguration(database, "ws://10.0.2.2:4984/beer-sample");
      config.replicatorType = ReplicatorType.pushAndPull;
      config.continuous = true;

      // Using self signed certificate
      //config.pinnedServerCertificate = "assets/cert-android.cer";
      config.authenticator = BasicAuthenticator(username, password);
      replicator = Replicator(config);

      replicator.addChangeListener((ReplicatorChange event) {
        if (event.status.error != null) {
          print("Error: " + event.status.error);
        }

        print(event.status.activity.toString());
      });

      await replicator.start();
      return true;
    } on PlatformException {
      return false;
    }
  }

  Future<void> logout() async {
    await Future.wait(pendingListeners);
    await replicator.removeChangeListener(_replicatorListenerToken);
    _replicatorListenerToken =
        replicator.addChangeListener((ReplicatorChange event) async {
      if (event.status.activity == ReplicatorActivityLevel.stopped) {
        await database.close();
        await replicator.removeChangeListener(_replicatorListenerToken);
        await replicator.dispose();
        _replicatorListenerToken = null;
      }
    });
    await replicator.stop();
  }

  Future<Document> createDocumentIfNotExists(String id, Map<String, dynamic> map) async {
    try {
      var oldDoc =  await database.document(id);
      if (oldDoc != null) return oldDoc;

      var newDoc = MutableDocument(id: id, data: map);
      if (await database.saveDocument(newDoc)) {
        return newDoc;
      } else {
        return null;
      }
    } on PlatformException {
      return null;
    }
  }

  ObservableResponse<ResultSet> getMyDocument(String documentId) {
    final stream = BehaviorSubject<ResultSet>();
    // Execute a query and then post results and all changes to the stream

    final Query query = QueryBuilder.select([
      SelectResult.expression(Meta.id.from("mydocs")).as("id"),
      SelectResult.expression(Expression.property("foo").from("mydocs")),
      SelectResult.expression(Expression.property("bar").from("mydocs")),
    ])
        .from(dbName, as: "mydocs")
        .where(Meta.id.from("mydocs").equalTo(Expression.string(documentId)));

    final processResults = (ResultSet results) {
      if (!stream.isClosed) {
        stream.add(results);
      }
    };

    return _buildObservableQueryResponse(stream, query, processResults);
  }

  ObservableResponse<T> _buildObservableQueryResponse<T>(
      BehaviorSubject<T> subject,
      Query query,
      ResultSetCallback resultsCallback) {
    final futureToken = query.addChangeListener((change) {
      if (change.results != null) {
        resultsCallback(change.results);
      }
    });

    final removeListener = () {
      final newFuture = futureToken.then((token) async {
        if (token != null) {
          await query.removeChangeListener(token);
        }
      });

      pendingListeners.add(newFuture);
      newFuture.whenComplete(() {
        pendingListeners.remove(newFuture);
      });
    };

    try {
      query.execute().then(resultsCallback);
    } on PlatformException {
      removeListener();
      rethrow;
    }

    return ObservableResponse<T>(subject, () {
      removeListener();
      subject.close();
    });
  }
}
```

```dart
class ObservableResponse<T> implements StreamController<T> {
  ObservableResponse(this._result, [this._onDispose]);

  final Subject<T> _result;
  final VoidCallback _onDispose;

  @override
  void add(data) => _result?.add(data);

  @override
  ControllerCallback get onCancel => throw UnsupportedError('ObservableResponses do not support cancel callbacks');

  @override
  ControllerCallback get onListen => throw UnsupportedError('ObservableResponses do not support listen callbacks');

  @override
  ControllerCallback get onPause => throw UnsupportedError('ObservableResponses do not support pause callbacks');

  @override
  ControllerCallback get onResume => throw UnsupportedError('ObservableResponses do not support resume callbacks');

  @override
  void addError(Object error, [StackTrace stackTrace]) => throw UnsupportedError('ObservableResponses do not support adding errors');

  @override
  Future addStream(Stream<T> source, {bool cancelOnError}) => throw UnsupportedError('ObservableResponses do not support adding streams');

  @override
  Future get done => _result?.done ?? true;

  @override
  bool get hasListener => _result?.hasListener ?? false;

  @override
  bool get isClosed => _result?.isClosed ?? true;

  @override
  bool get isPaused => _result?.isPaused ?? false;

  @override
  StreamSink<T> get sink => _result?.sink;

  @override
  Stream<T> get stream => _result?.stream;

  @override
  Future<dynamic> close() {
    if (_onDispose != null) {
      // Do operations here like closing streams and removing listeners
      _onDispose();
    }

    return _result?.close();
  }

  @override
  set onCancel(Function() onCancelHandler) => throw UnsupportedError('ObservableResponses do not support cancel callbacks');

  @override
  set onListen(void Function() onListenHandler) => throw UnsupportedError('ObservableResponses do not support listen callbacks');

  @override
  set onPause(void Function() onPauseHandler) => throw UnsupportedError('ObservableResponses do not support pause callbacks');

  @override
  set onResume(void Function() onResumeHandler) => throw UnsupportedError('ObservableResponses do not support resume callbacks');
}
```
