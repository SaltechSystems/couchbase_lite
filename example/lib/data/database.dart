// Copyright 2020-present the Saltech Systems authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'package:couchbase_lite_example/models/database/beer.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:couchbase_lite/couchbase_lite.dart';
import 'package:built_collection/built_collection.dart';

import 'package:couchbase_lite_example/data/observable_response.dart';

typedef ResultSetCallback = void Function(ResultSet results);

class AppDatabase {
  AppDatabase._internal();

  static final AppDatabase instance = AppDatabase._internal();

  String dbName = "myDatabase";
  List<Future> pendingListeners = List();
  ListenerToken _replicatorListenerToken;
  Database database;
  Replicator replicator;
  ListenerToken _docListenerToken;
  ListenerToken _dbListenerToken;

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

      const indexName = "TypeNameIndex";
      var indices = await database.indexes;
      if (!indices.contains(indexName)) {
        var index = IndexBuilder.valueIndex(items: [
          ValueIndexItem.property("type"),
          ValueIndexItem.expression(Expression.property("name"))
        ]);
        await database.createIndex(index, withName: indexName);
      } else {
        var query = _buildBeerQuery(100, 0, false);
        print('explanation:');
        print(await query.explain());
      }

      var pref =
          await createDocumentIfNotExists("MyPreference", {"theme": "dark"});
      _docListenerToken = database.addDocumentChangeListener(pref.id, (change) {
        print("Document change ${change.documentID}");
      });

      _dbListenerToken = database.addChangeListener((dbChange) {
        for (var change in dbChange.documentIDs) {
          print("change in id: $change");
        }
      });

      return true;
    } on PlatformException {
      return false;
    }
  }

  Future<void> logout() async {
    await Future.wait(pendingListeners);

    await database.removeChangeListener(_docListenerToken);
    await database.removeChangeListener(_dbListenerToken);
    _docListenerToken = null;
    _dbListenerToken = null;

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

  Future<Document> createDocumentIfNotExists(
      String id, Map<String, dynamic> map) async {
    try {
      var oldDoc = await database.document(id);
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

  ObservableResponse<BuiltList<Beer>> getBeer(
      int limit, int offset, bool isDescending) {
    final beerMapSubject = BehaviorSubject<BuiltList<Beer>>();
    // Here we would do the query and maybe add a change listener to post the
    // results to the stream

    final query = _buildBeerQuery(limit, offset, isDescending);

    final processResults = (ResultSet results) {
      final model = results.map((result) {
        return Beer.fromMap(result.toMap());
      }).toList();

      if (!beerMapSubject.isClosed) {
        beerMapSubject.add(BuiltList(model));
      }
    };

    return _buildObservableQueryResponse(beerMapSubject, query, processResults);
  }

  Query _buildBeerQuery(int limit, int offset, bool isDescending) {
    return QueryBuilder.select([
      SelectResult.expression(Meta.id.from("beer")).as("beerID"),
      SelectResult.expression(Expression.property("name").from("beer")),
    ])
        .from(dbName, as: "beer")
        .where(Expression.property("type")
            .from("beer")
            .equalTo(Expression.string("beer")))
        .orderBy([
      isDescending
          ? Ordering.expression(Expression.property("name").from("beer"))
              .descending()
          : Ordering.expression(Expression.property("name").from("beer"))
              .ascending()
    ]).limit(Expression.intValue(limit), offset: Expression.intValue(offset));
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
