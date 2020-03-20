import 'dart:async';
import 'dart:collection';

import 'package:couchbase_lite/couchbase_lite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _documentCount = 'Initializing';
  Database database;
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
      database = await Database.initWithName(dbName);
      _insertDummyData();
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
          child: RaisedButton(
            onPressed: () {
              //a variable to represent an element in the forms.primary_form.formData.assigned_to array
              VariableExpression assignedToVariableExpression = ArrayExpression
                  .variable("assigned_to");
              //a variable to represent every element in the assigned_to array
              Expression assignedToArrayExpression = Expression.property(
                  "forms.primary_form.formData.assigned_to");
              Expression assignedToIdExpression = ArrayExpression.variable(
                  "assigned_to.id");

              Query query = QueryBuilder
                  .select([SelectResult.property("index"),SelectResult.property("value"),SelectResult.expression(Functions.count(Expression.string("*")))])
                  .from(dbName)
                  .groupBy(List<Expression>()..add(Expression.property("index")));
              query.execute().then((resultSet) {
                print(resultSet.allResults().length);
                resultSet.allResults().forEach((result) {
                  print(" result ooo ${result.getInt(key:"index")}");
                });
              });
            },
          ),
        ),
      ),
    );
  }

  void _insertDummyData() {
    for (int i = 0; i < 10; i++) {
      HashMap<String, dynamic> map = HashMap();
      map["name"] = i.toString();
      map["index"] = i%2;
      print("Dummy data index${i%2}");
      database.saveDocumentWithId(i.toString(), Document(map));
    }
  }
}
