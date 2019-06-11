# couchbase_lite plugin

Flutter plugin for Couchbase Lite Community Edition. An embedded lightweight, noSQL database with live synchronization and offline support on Android and iOS.

The goal of this project is to align this library with the [Swift SDK API](https://docs.couchbase.com/mobile/2.5.0/couchbase-lite-swift/) for Couchbase Lite.

*Note*: This plugin is still under development, and some APIs might not be available yet.
[Feedback](https://github.com/bawelter/couchbase_lite/issues) and [Pull Requests](https://github.com/bawelter/couchbase_lite/pulls) are most welcome!

This project forked from [Fluttercouch](https://github.com/oltrenuovefrontiere/fluttercouch)

## Getting Started

In your flutter project add the dependency:

```yaml
dependencies:
  couchbase_lite: ^2.5.1+2
  
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

[Swift SDK API References](https://docs.couchbase.com/mobile/2.5.0/couchbase-lite-swift/)

[Java SDK API References](http://docs.couchbase.com/mobile/2.5.0/couchbase-lite-java)

*Note*: Syntax follows the Swift SDK but these are the SDKs used for the platform code.

## Usage example

Below is an example for the database using the BLoC pattern ( View <-> BLoC <-> Repository <-> Database )

The files can also be found in the plugin example but are not used in the main.dart.  The example will be revised in the near future to use the BLoC pattern.

```dart
class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();

  AppDatabase._internal();

  String dbName = "myDatabase";
  List<Future> pendingListeners = List();
  ListenerToken _replicatorListenerToken;
  Database database;
  Replicator replicator;

  Future<bool> login(String username, String password) async {
    try {
      database = await Database.initWithName(dbName);
      // Note wss://10.0.2.2:4984/my-database is for the android simulator on your local machine's couchbase database
      ReplicatorConfiguration config = ReplicatorConfiguration(database, "wss://10.0.2.2:4984/my-database");
      config.replicatorType = ReplicatorType.pushAndPull;
      config.continuous = true;

      // Using self signed certificate
      config.pinnedServerCertificate = "assets/cert-android.cer";
      config.authenticator = BasicAuthenticator(username, password);
      replicator = Replicator(config);

      replicator.addChangeListener((ReplicatorChange event) {
        if (event.status.error != null) {
          print("Error: " + event.status.error);
        }

        print(event.status.activity.toString());
      });

      replicator.start();
      return true;
    } on PlatformException {
      return false;
    }
  }

  Future<void> logout() async {
    await Future.wait(pendingListeners);
    replicator.removeChangeListener(_replicatorListenerToken);
    _replicatorListenerToken = replicator.addChangeListener((ReplicatorChange event) async {
      if (event.status.activity == ReplicatorActivityLevel.stopped) {
        await database.close();
        replicator.removeChangeListener(_replicatorListenerToken);
        _replicatorListenerToken = null;
      }
    });
    await replicator.stop();
  }

  Future<Map<String,dynamic>> createDocument(Map<String,dynamic> map) async {
    var id = "mydocument::${Uuid().v1()}";

    try {
      String documentId = await database.saveDocumentWithId(id, Document(map));
      var newDoc = Map.from(map);
      newDoc["id"] = documentId;
      return newDoc;
    } on PlatformException {
      return null;
    }
  }

  ObservableResponse<ResultSet> getMyDocument(String documentId) {
    final stream = BehaviorSubject<ResultSet>();
    // Execute a query and then post results and all changes to the stream

    final Query query = QueryBuilder
        .select([
      SelectResult.expression(Meta.id.from("mydocs")).As("id"),
      SelectResult.expression(Expression.property("foo").from("mydocs")),
      SelectResult.expression(Expression.property("bar").from("mydocs")),
    ])
        .from(dbName, as: "mydocs")
        .where(Meta.id.from("mydocs").equalTo(Expression.string(documentId))
    );

    final processResults = (ResultSet results) {
      if (!stream.isClosed) {
        stream.add(results);
      }
    };

    return _buildObservableQueryResponse(stream, query, processResults);
  }

  ObservableResponse<T> _buildObservableQueryResponse<T>(BehaviorSubject<T> subject, Query query, ResultSetCallback resultsCallback) {
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
      newFuture.whenComplete((){pendingListeners.remove(newFuture);});
    };

    try {
      query.execute().then(resultsCallback);
    } on PlatformException {
      removeListener();
      rethrow;
    }

    return ObservableResponse<T>(subject.debounce(Duration(seconds: 1)), () {
      removeListener();
      subject.close();
    });
  }
}
```

```dart
class ObservableResponse<T> {
  final Observable<T> result;
  final VoidFunc onDispose;
  ObservableResponse(this.result,this.onDispose);

  void dispose() {
    if (onDispose != null) {
      // Do operations here like closing streams and removing listeners
      onDispose();
    }
  }
}
```
