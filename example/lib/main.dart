import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:couchbase_lite/couchbase_lite.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _documentCount = 'Initializing';
  Database database;

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
      database = await Database.initWithName("MyNewCouchbaseDB");
      await database.saveDocumentWithId("test", Document({}));
      int count = await database.count;
      result = "Document Count: $count";
    } on PlatformException catch (e) {
      result = 'Failed to initialize database. ${e.toString()}';
    }

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
        body: Center(
          child: Text(_documentCount),
        ),
      ),
    );
  }
}
