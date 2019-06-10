import 'package:couchbase_lite/database.dart';
import 'package:couchbase_lite/document.dart';
import 'package:couchbase_lite/query/query.dart';
import 'package:couchbase_lite/query/query_builder.dart';
import 'package:couchbase_lite/query/select_result.dart';
import 'package:couchbase_lite/replicator.dart';
import 'package:couchbase_lite/replicator_configuration.dart';
import 'package:couchbase_lite/authenticator.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel databaseChannel = MethodChannel('com.saltechsystems.couchbase_lite/database');
  const MethodChannel jsonChannel = MethodChannel('com.saltechsystems.couchbase_lite/json',JSONMethodCodec());

  setUp(() {
    databaseChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      Map<dynamic,dynamic> arguments = methodCall.arguments;
      if (!arguments.containsKey("database")) {
        return PlatformException(code: "errArgs", message: "Error: Missing database", details: methodCall.arguments.toString());
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
            return PlatformException(code: "errArgs", message: "invalid arguments", details: null);
          }
          break;
        case ("saveDocumentWithId"):
          if (arguments.containsKey("id") && arguments.containsKey("map")) {
            return arguments["id"];
          } else {
            return PlatformException(code: "errArgs", message: "invalid arguments", details: null);
          }
          break;
        case ("getDocumentWithId"):
          if (arguments.containsKey("id")) {
            return {"testdoc":"test"};
          } else {
            return PlatformException(code: "errArgs", message: "Query Error: Invalid Arguments", details: arguments.toString());
          }

          break;
        case ("deleteDocumentWithId"):
          if (arguments.containsKey("id")) {
            return null;
          } else {
            return PlatformException(code: "errArgs", message: "Query Error: Invalid Arguments", details: arguments.toString());
          }
          break;
        case ("getDocumentCount"):
          return 1;
        default:
          return UnimplementedError();
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
        case "startReplicator":
          return null;
          break;
        case "stopReplicator":
          return null;
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
    expect(await database.saveDocument(Document({})),"documentid");
    expect(await database.saveDocumentWithId("docid", Document({})),"docid");
    expect(await database.documentWithId("myid"),{"testdoc":"test"});
  });

  test('testQuery', () async {
    Query query = QueryBuilder.select([SelectResult.all()]).from("test", as: "sheets");
    query.execute();
  });

  test('testReplicator', () async {
    Database database = await Database.initWithName("testdb");
    ReplicatorConfiguration config = ReplicatorConfiguration(database, "wss://10.0.2.2:4984/local-android-db");
    config.replicatorType = ReplicatorType.pushAndPull;
    config.continuous = true;
    config.pinnedServerCertificate = "assets/cert-android.cer";
    config.authenticator = BasicAuthenticator("username", "password");
    Replicator replicator = Replicator(config);
    replicator.start();
  });
}
