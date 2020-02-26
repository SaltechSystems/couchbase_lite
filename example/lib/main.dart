import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:couchbase_lite/couchbase_lite.dart';
import 'package:encrypt/encrypt.dart' as aes;
import 'package:crypto/crypto.dart';
import 'package:hex/hex.dart';
import 'package:password_hash/pbkdf2.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _documentCount = 'Initializing';
  Database database;
  Replicator replicator;
  bool init = true;
  int s;
  int idx = 0;
  final TextEditingController controller = TextEditingController();
  String docText = '';

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
      ReplicatorConfiguration config = ReplicatorConfiguration(
          database, "ws://192.168.1.75:4984/spirit-bucket");
      config.replicatorType = ReplicatorType.pushAndPull;
      config.continuous = true;
      config.channels = ['master','spiritchannel'];
      config.pushAttributeKeyFilter = 'type';
      config.pushAttributeValuesFilter = ['localdoc'];
      config.headers = {'Authentication': 'Bearer token'};

      // Using self signed certificate
      replicator = Replicator(config);

      replicator.addChangeListener((ReplicatorChange event) async {
        if (init) {
          init = false;
          s = DateTime.now().millisecondsSinceEpoch;
        }
        if (event.status.error != null) {
          print("Error: " + event.status.error);
        }

        print(event.status.activity.toString());
        if (event.status.activity == ReplicatorActivityLevel.busy ||
            event.status.activity == ReplicatorActivityLevel.connecting) {
          return;
        }

//        Query query = QueryBuilder.select([SelectResult.expression(Functions.count(Expression.all()))])
//            .from(database.name)
//            .where(Expression.property("type").iS(Expression.string("villagecode")));
//        ResultSet qresult = await query.execute();
        int count = await database.count;
        int e = DateTime.now().millisecondsSinceEpoch;
        final m = ((e - s) ~/ 60000);
        final ss = ((e - s) % 60000) / 1000;
        result = "Document Count: $count ($m:$ss)";
        setState(() {
          _documentCount = result;
        });
      });

      await replicator.start();
    } on PlatformException catch (e) {
      //result = 'Failed to initialize database. ${e.toString()}';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              RaisedButton(
                onPressed: () async {
                  final t = DateTime.now();
                  final id = t.millisecondsSinceEpoch.toString();
                  MutableDocument mutableDoc = MutableDocument();
                  mutableDoc.id = id;
                  mutableDoc.setString('id', id);
                  mutableDoc.setArray('channels', ['spiritchannel']);
                  mutableDoc.setString('time', t.toIso8601String());
                  if ((idx % 2) == 0) {
                    mutableDoc.setString('type', 'localdoc');
                  } else {
                    mutableDoc.setString('type', 'notlocaldoc');
                  }
                  idx++;
                  await database.save(mutableDoc);
                  setState(() {
                    controller.text = id;
                    docText = '';
                  });
                },
                child: Text(_documentCount),
              ),
              TextField(
                controller: controller,
              ),
              RaisedButton(
                  onPressed: () async {
                    Query query = QueryBuilder.select([SelectResult.all()])
                        .from(database.name)
                        .where(Expression.property("id")
                            .iS(Expression.string(controller.text)));
                    ResultSet qresult = await query.execute();
                    setState(() {
                      if (qresult.isNotEmpty) {
                        final d = qresult.elementAt(0).toMap();
                        if (d['spirit-bucket'] != null &&
                            d['spirit-bucket']['data'] != null) {
                          final generator = PBKDF2(hashAlgorithm: sha1);
                          final key = aes.Key.fromBase16(HEX.encode(generator.generateKey("123456", "123456", 1, 32)));
                          final iv = aes.IV.fromBase16(HEX.encode(generator.generateKey("123456", "123456", 1, 16)));

                          final encrypter = aes.Encrypter(aes.AES(key, mode: aes.AESMode.cbc, padding: 'PKCS7'));

                          try {
                            final decrypted = encrypter.decrypt64(
                                d['spirit-bucket']['data'], iv: iv);
                            d['spirit-bucket']['decripted'] = decrypted;
                            docText = d.toString();
                          } catch (ex) {
                            print(ex);
                          }
                        } else {
                          docText = d.toString();
                        }
                      } else {
                        docText = '${controller.text} not found';
                      }
                    });
//                    query = QueryBuilder.select([SelectResult.all()])
//                        .from(database.name)
//                        .where(Expression.property("id")
//                        .iS(Expression.string(controller.text)));
//                    qresult = await query.execute();
//                    for (final q in qresult) {
//                      final id = q.toMap();
//                      final doc = await database.documentWithId(id['spirit-bucket']['id']);
//                      MutableDocument tDoc =  doc.toMutable();
//                      tDoc.setString('content', 'edited');
//                      await database.save(tDoc);
//                      tDoc.setString('content', 'edited again');
//                      await database.save(tDoc);
//                    }
                  },
                  child: Text('Document check'),
              ),
              Text('$docText'),
            ],
          ),
        ),
      ),
    );
  }
}
