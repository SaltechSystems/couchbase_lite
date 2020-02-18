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
  Replicator replicator;

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
      database = await Database.initWithName("spirit-bucket");
      await database.saveDocumentWithId(DateTime.now().toIso8601String(), Document({}));
      ReplicatorConfiguration config =
      ReplicatorConfiguration(database, "ws://192.168.1.75:4984/spirit-bucket");
      config.replicatorType = ReplicatorType.pushAndPull;
      config.continuous = true;
      config.channels = ['spiritchannel'];

      // Using self signed certificate
      replicator = Replicator(config);

      replicator.addChangeListener((ReplicatorChange event) async {
        if (event.status.error != null) {
          print("Error: " + event.status.error);
        }

        print(event.status.activity.toString());
        int count = await database.count;
        result = "Document Count: $count";
        setState(() {
          _documentCount = result;
        });
      });

      await replicator.start();
    } on PlatformException catch (e) {
      result = 'Failed to initialize database. ${e.toString()}';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;


  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: RaisedButton(
            onPressed: () async {
              final doc = await database.documentWithId('1234567');
              print(doc);
            },
            child: Text(_documentCount),),
        ),
      ),
    );
  }
}
