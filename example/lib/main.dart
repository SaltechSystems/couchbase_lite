import 'dart:async';
import 'dart:collection';

import 'package:couchbase_lite/couchbase_lite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

import 'database.dart';
import 'observable_response.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _documentCount = 'Initializing';
  AppDatabase appDatabase = AppDatabase.instance;
  ObservableResponse<ResultSet> myObservableResponse;
  final _documentID = "foobar";
  final _foo = BehaviorSubject<int>();
  final _bar = BehaviorSubject<int>();

  final String dbName = "MyNewCouchbaseDB";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      // This is an example only normally the appDatabase would be only accessed inside BLoC (Business Logic Components)
      await appDatabase.login("foo_user", "password");
      int count = await appDatabase.database.count;
      result = "Document Count: $count";
    } on PlatformException catch (e) {
      result = 'Failed to initialize database. ${e.toString()}';
    }

    // This example is just to show an example of using streams we would normally handle this setup in the BLoC component
    myObservableResponse = appDatabase.getMyDocument(_documentID);

    // Populate the streams with some data
    myObservableResponse.stream.listen((resultSet) {
      if (resultSet.isNotEmpty) {
        _foo.add(resultSet.first.getInt(key: "foo") ?? -1);
        _bar.add(resultSet.first.getInt(key: "bar") ?? -1);
      } else {
        _foo.add(null);
        _bar.add(null);
      }
    });

    // Create the document if it doesn't already exist
    await appDatabase.createDocumentIfNotExists(
        _documentID, {
        "foo": 1,
        "bar": 1
      }
    );

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _documentCount = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(child: Text("Foo / Bar Document ID: $_documentID")),
            StreamBuilder(
              stream: _foo.stream,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                return RaisedButton(
                  child: Text('Increment Foo Counter: ${snapshot.data ?? "N/A"}'),
                  onPressed: snapshot.hasData ? () async {
                    // This is an example only this normally would be inside BLoC (Business Logic Component)
                    var rtnDoc = await appDatabase.database.document(_documentID);
                    var myDoc = rtnDoc.toMutable();
                    myDoc.setInt("foo", snapshot.data + 1);

                    // This will fail if the document is updated while we are increasing the count
                    await appDatabase.database.saveDocument(myDoc);
                  } : null,
                );
              }),
            StreamBuilder(
                stream: _bar.stream,
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  return RaisedButton(
                    child: Text('Increment Bar Counter: ${snapshot.data ?? "N/A"}'),
                    onPressed: snapshot.hasData ? () async {
                      // This is an example only this normally would be inside BLoC (Business Logic Component)
                      var rtnDoc = await appDatabase.database.document(_documentID);
                      var myDoc = rtnDoc.toMutable();
                      myDoc.setInt("bar", snapshot.data + 1);

                      // This will use lastWriteWins so it should never fail
                      await appDatabase.database.saveDocument(myDoc);
                    } : null,
                  );
                }),
            Container(height: 20),
            RaisedButton(
              child: Text('Refresh Document Count'),
              onPressed: () async {
                int count = await appDatabase.database.count;

                if (mounted) {
                  setState(() {
                    _documentCount = "Document Count: $count";
                  });
                }
              },
            ),
            Center(child: Text(_documentCount)),
        ],)
      ),
    );
  }

  @override
  void dispose() {
    // Close all streams properly
    _foo.close();
    _bar.close();
    myObservableResponse?.close();
    appDatabase.logout();
    super.dispose();
  }
}
