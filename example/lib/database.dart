//import 'dart:async';
//import 'package:flutter/services.dart';
//import 'package:rxdart/rxdart.dart';
//import 'package:uuid/uuid.dart';
//
//import 'observable_response.dart';
//import 'package:couchbase_lite/couchbase_lite.dart';
//
//typedef ResultSetCallback = void Function(ResultSet results);
//
//class AppDatabase {
//  AppDatabase._internal();
//
//  static final AppDatabase instance = AppDatabase._internal();
//
//  String dbName = "myDatabase";
//  List<Future> pendingListeners = List();
//  ListenerToken _replicatorListenerToken;
//  Database database;
//  Replicator replicator;
//
//  Future<bool> login(String username, String password) async {
//    try {
//      database = await Database.initWithName(dbName);
//      // Note wss://10.0.2.2:4984/my-database is for the android simulator on your local machine's couchbase database
//      ReplicatorConfiguration config =
//          ReplicatorConfiguration(database, "wss://10.0.2.2:4984/my-database");
//      config.replicatorType = ReplicatorType.pushAndPull;
//      config.continuous = true;
//
//      // Using self signed certificate
//      config.pinnedServerCertificate = "assets/cert-android.cer";
//      config.authenticator = BasicAuthenticator(username, password);
//      replicator = Replicator(config);
//
//      replicator.addChangeListener((ReplicatorChange event) {
//        if (event.status.error != null) {
//          print("Error: " + event.status.error);
//        }
//
//        print(event.status.activity.toString());
//      });
//
//      await replicator.start();
//      return true;
//    } on PlatformException {
//      return false;
//    }
//  }
//
//  Future<void> logout() async {
//    await Future.wait(pendingListeners);
//    replicator.removeChangeListener(_replicatorListenerToken);
//    _replicatorListenerToken =
//        replicator.addChangeListener((ReplicatorChange event) async {
//      if (event.status.activity == ReplicatorActivityLevel.stopped) {
//        await database.close();
//        // Change listeners will be
//        //replicator.removeChangeListener(_replicatorListenerToken);
//        await replicator.dispose();
//        _replicatorListenerToken = null;
//      }
//    });
//    await replicator.stop();
//  }
//
//  Future<Map<String, dynamic>> createDocument(Map<String, dynamic> map) async {
//    var id = "mydocument::${Uuid().v1()}";
//
//    try {
//      String documentId = await database.saveDocumentWithId(id, Document(map));
//      var newDoc = Map.from(map);
//      newDoc["id"] = documentId;
//      return newDoc;
//    } on PlatformException {
//      return null;
//    }
//  }
//
//  ObservableResponse<ResultSet> getMyDocument(String documentId) {
//    final stream = BehaviorSubject<ResultSet>();
//    // Execute a query and then post results and all changes to the stream
//
//    final Query query = QueryBuilder.select([
//      SelectResult.expression(Meta.id.from("mydocs")).as("id"),
//      SelectResult.expression(Expression.property("foo").from("mydocs")),
//      SelectResult.expression(Expression.property("bar").from("mydocs")),
//    ])
//        .from(dbName, as: "mydocs")
//        .where(Meta.id.from("mydocs").equalTo(Expression.string(documentId)));
//
//    final processResults = (ResultSet results) {
//      if (!stream.isClosed) {
//        stream.add(results);
//      }
//    };
//
//    return _buildObservableQueryResponse(stream, query, processResults);
//  }
//
//  ObservableResponse<T> _buildObservableQueryResponse<T>(
//      BehaviorSubject<T> subject,
//      Query query,
//      ResultSetCallback resultsCallback) {
//    final futureToken = query.addChangeListener((change) {
//      if (change.results != null) {
//        resultsCallback(change.results);
//      }
//    });
//
//    final removeListener = () {
//      final newFuture = futureToken.then((token) async {
//        if (token != null) {
//          await query.removeChangeListener(token);
//        }
//      });
//
//      pendingListeners.add(newFuture);
//      newFuture.whenComplete(() {
//        pendingListeners.remove(newFuture);
//      });
//    };
//
//    try {
//      query.execute().then(resultsCallback);
//    } on PlatformException {
//      removeListener();
//      rethrow;
//    }
//
//    return ObservableResponse<T>(subject.debounce(Duration(seconds: 1)), () {
//      removeListener();
//      subject.close();
//    });
//  }
//}
