import 'package:couchbase_lite/couchbase_lite.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel databaseChannel =
      MethodChannel('com.saltechsystems.couchbase_lite/database');
  const MethodChannel replicatorChannel =
      MethodChannel('com.saltechsystems.couchbase_lite/replicator');
  const MethodChannel jsonChannel = MethodChannel(
      'com.saltechsystems.couchbase_lite/json', JSONMethodCodec());

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    databaseChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      Map<dynamic, dynamic> arguments = methodCall.arguments;
      if (!arguments.containsKey("database")) {
        return PlatformException(
            code: "errArgs",
            message: "Error: Missing database",
            details: methodCall.arguments.toString());
      }

      switch (methodCall.method) {
        case ("initDatabaseWithName"):
          return arguments["database"];
          break;
        case ("closeDatabaseWithName"):
          return null;
          break;
        case ("deleteDatabaseWithName"):
          return null;
          break;
        case ("delete"):
          return null;
          break;
        case ("saveDocument"):
          if (arguments.containsKey("map")) {
            return {
              "id": "documentid",
              "sequence": 1,
              "success": true,
              "doc": arguments["map"]
            };
          } else {
            return PlatformException(
                code: "errArgs", message: "invalid arguments", details: null);
          }
          break;
        case ("saveDocumentWithId"):
          if (arguments.containsKey("map") && arguments.containsKey("id")) {
            return {
              "id": arguments["id"],
              "sequence": 1,
              "success": true,
              "doc": arguments["map"]
            };
          } else {
            return PlatformException(
                code: "errArgs", message: "invalid arguments", details: null);
          }
          break;
        case ("getDocumentWithId"):
          if (arguments.containsKey("id")) {
            return {
              "id": arguments["id"],
              "doc": {"testdoc": "test"}
            };
          } else {
            return PlatformException(
                code: "errArgs",
                message: "Query Error: Invalid Arguments",
                details: arguments.toString());
          }

          break;
        case ("deleteDocumentWithId"):
          if (arguments.containsKey("id")) {
            return true;
          } else {
            return PlatformException(
                code: "errArgs",
                message: "Query Error: Invalid Arguments",
                details: arguments.toString());
          }
          break;
        case ("getDocumentCount"):
          return 1;
        case ("compactDatabaseWithName"):
          return null;
        case ("getIndexes"):
          return [];
        case ("createIndex"):
          if (arguments.containsKey("index") &&
              arguments.containsKey("withName")) {
            return true;
          } else {
            return PlatformException(
                code: "errArgs",
                message: "Query Error: Invalid Arguments",
                details: arguments.toString());
          }
          break;
        case ("deleteIndex"):
          if (arguments.containsKey("forName")) {
            return true;
          } else {
            return PlatformException(
                code: "errArgs",
                message: "Query Error: Invalid Arguments",
                details: arguments.toString());
          }
          break;
        case ("addDocumentChangeListener"):
          return null;
          break;
        case ("addChangeListener"):
          return null;
          break;
        case ("removeChangeListener"):
          return null;
          break;
        default:
          return UnimplementedError();
      }
    });

    replicatorChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      Map<dynamic, dynamic> arguments = methodCall.arguments;
      if (!arguments.containsKey("replicatorId")) {
        return PlatformException(
            code: "errArgs",
            message: "Error: Missing replicator",
            details: methodCall.arguments.toString());
      }

      switch (methodCall.method) {
        case "start":
          return [];
          break;
        case "stop":
          return true;
          break;
        case "resetCheckpoint":
          return true;
          break;
        case "dispose":
          return null;
          break;
        default:
          return UnimplementedError();
          break;
      }
    });

    jsonChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case "executeQuery":
          return [];
          break;
        case "storeQuery":
          return true;
          break;
        case "removeQuery":
          return true;
          break;
        case "explainQuery":
          return "query explained! Should not contain SCAN TABLE";
          break;
        case "storeReplicator":
          return null;
          break;
        default:
          return UnimplementedError();
          break;
      }
    });
  });

  tearDown(() {
    databaseChannel.setMethodCallHandler(null);
    replicatorChannel.setMethodCallHandler(null);
    jsonChannel.setMockMethodCallHandler(null);
  });

  test('testDatabase', () async {
    Database database = await Database.initWithName("testdb");
    await database.close();
    await database.deleteDocument("docid");
    expect(await database.count, 1);
    expect(await database.saveDocument(MutableDocument()), true);
    expect(await database.saveDocument(MutableDocument(id: "docid")), true);
    MutableDocument doc = MutableDocument();
    await database.saveDocument(doc);
    expect(doc.id, "documentid");
    await database.saveDocument(doc);
    expect(doc.id, "documentid");
    var testDoc = await database.document("myid");
    expect(testDoc, isNotNull);
    expect(testDoc!.id, "myid");
    expect(await database.deleteDocument("myid"), true);
    // Code Coverage for deprecate functions
    // ignore: deprecated_member_use_from_same_package
    await database.documentWithId("myid");
    // ignore: deprecated_member_use_from_same_package
    await database.save(MutableDocument());

    var token = database.addChangeListener((dbChnage) => {});
    token = await database.removeChangeListener(token);
    expect(token, isNotNull);

    token = database.addDocumentChangeListener("myid", (change) => {});
    await database.removeChangeListener(token);

    var index = IndexBuilder.valueIndex(items: [
      ValueIndexItem.property("type"),
      ValueIndexItem.property("name"),
      ValueIndexItem.expression(Expression.property('owner'))
    ]);

    List<Map<String, dynamic>> expected = [
      {"property": "type"},
      {"property": "name"},
      {
        "expression": [
          {"property": "owner"}
        ]
      },
    ];

    expect(index.toJson(), expected);
    await database.createIndex(index, withName: "MyIndex");
    await database.deleteIndex(forName: "MyIndex");

    await database.indexes;
    await database.compact();
    await database.delete();
    await Database.deleteWithName("testdb");
  });

  test('testQuery', () async {
    Query query =
        QueryBuilder.select([SelectResult.all()]).from("test", as: "sheets");
    await query.execute();
    //expect(await query.parameters, throwsUnimplementedError);
    expect(await query.explain(), isNotNull);
  });

  test('testQueryChangeListener', () async {
    Query query =
        QueryBuilder.select([SelectResult.all()]).from("test", as: "sheets");
    var token = await query.addChangeListener((change) {
      //Do Something
    });
    await query.execute();
    await query.removeChangeListener(token);
  });

  test('testReplicator', () async {
    BasicAuthenticator authenticator =
        BasicAuthenticator("username", "password");
    Map<String, dynamic> extected = {
      "database": "testdb",
      "target": "wss://10.0.2.2:4984/local-android-db",
      "replicatorType": "PUSH_AND_PULL",
      "continuous": true,
      "pinnedServerCertificate": "assets/cert-android.cer",
      "authenticator": authenticator,
    };
    Database database = await Database.initWithName("testdb");
    ReplicatorConfiguration config = ReplicatorConfiguration(
        database, "wss://10.0.2.2:4984/local-android-db");
    config.continuous = true;
    config.pinnedServerCertificate = "assets/cert-android.cer";
    config.authenticator = authenticator;
    config.replicatorType = ReplicatorType.pushAndPull;
    expect(config.toJson(), extected);
    config.replicatorType = ReplicatorType.push;
    extected["replicatorType"] = "PUSH";
    expect(config.toJson(), extected);
    config.replicatorType = ReplicatorType.pull;
    extected["replicatorType"] = "PULL";
    expect(config.toJson(), extected);
    Replicator replicator = Replicator(config);

    await replicator.addChangeListener((change) {});
    await replicator.addDocumentReplicationListener((replication) {});
    await replicator.start();
    await replicator.stop();
    await replicator.resetCheckpoint();
    await replicator.dispose();
  });

  test('testReplicatorActivity', () async {
    expect(ReplicatorStatus.activityFromString("BUSY"),
        ReplicatorActivityLevel.busy);
    expect(ReplicatorStatus.activityFromString("IDLE"),
        ReplicatorActivityLevel.idle);
    expect(ReplicatorStatus.activityFromString("OFFLINE"),
        ReplicatorActivityLevel.offline);
    expect(ReplicatorStatus.activityFromString("STOPPED"),
        ReplicatorActivityLevel.stopped);
    expect(ReplicatorStatus.activityFromString("CONNECTING"),
        ReplicatorActivityLevel.connecting);
  });

  test('basicAuthenticator', () async {
    var auth = BasicAuthenticator("username", "password");
    expect(auth.toJson(),
        {"method": "basic", "username": "username", "password": "password"});
  });

  test('sessionAuthenticator', () async {
    var auth = SessionAuthenticator("sessionId");
    expect(auth.toJson(),
        {"method": "session", "sessionId": "sessionId", "cookieName": null});
  });
}
