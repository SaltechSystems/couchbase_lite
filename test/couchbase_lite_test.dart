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
            return 'documentid';
          } else {
            return PlatformException(
                code: "errArgs", message: "invalid arguments", details: null);
          }
          break;
        case ("saveDocumentWithId"):
          if (arguments.containsKey("id") && arguments.containsKey("map")) {
            return arguments["id"];
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
            return null;
          } else {
            return PlatformException(
                code: "errArgs",
                message: "Query Error: Invalid Arguments",
                details: arguments.toString());
          }
          break;
        case ("getDocumentCount"):
          return 1;
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
    jsonChannel.setMockMethodCallHandler(null);
  });

  test('testDatabase', () async {
    Database database = await Database.initWithName("testdb");
    await database.close();
    await database.deleteDocument("docid");
    expect(await database.count, 1);
    expect(await database.saveDocument(Document({})), "documentid");
    expect(await database.saveDocumentWithId("docid", Document({})), "docid");
    await database.documentWithId("myid");
  });

  test('testQuery', () async {
    Query query =
        QueryBuilder.select([SelectResult.all()]).from("test", as: "sheets");
    await query.execute();
    //expect(await query.parameters, throwsUnimplementedError);
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
