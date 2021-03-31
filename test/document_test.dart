import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:couchbase_lite/couchbase_lite.dart';

void main() {
  Map? initializer;
  late Document document;
  late MutableDocument mutableDocument;
  setUp(() {
    initializer = Map();
    initializer!['string'] = "string";
    initializer!['double'] = 3.14;
    initializer!['int'] = 12;
    initializer!['map'] = {};
    initializer!['boolInt'] = 0;
    initializer!['bool'] = true;
    initializer!['list'] = [];
    document = MutableDocument(data: initializer, id: "123456789");
    mutableDocument = MutableDocument();
  });

  test("Document: getting string", () {
    expect(document.count(), initializer!.length);
  });
  test("Document: getting string", () {
    expect(document.getString('string'), "string");
  });
  test("Document: getting double", () {
    expect(document.getDouble('double'), 3.14);
    expect(document.getInt('double'), 3.14.toInt());
  });
  test("Document: getting int", () {
    expect(document.getInt('int'), 12);
  });
  test("Document: getting double int", () {
    expect(document.getDouble('int'), 12);
  });
  test("Document: getting map", () {
    expect(document.getMap('map'), {});
  });
  test("Document: getting list", () {
    // ignore: deprecated_member_use_from_same_package
    expect(document.getArray('list'), []);
    expect(document.getList('list'), []);
  });
  test("Document: to map", () {
    expect(document.toMap(), initializer);
  });
  test("Document: getting bool", () {
    expect(document.getBoolean("bool"), true);
  });
  test("Document: getting bool int", () {
    expect(document.getBoolean("boolInt"), false);
  });
  test("Document: null list", () {
    expect(document.getMap("null"), null);
  });
  test("Document: null list", () {
    // ignore: deprecated_member_use_from_same_package
    expect(document.getArray("null"), null);
    expect(document.getList("null"), null);
  });
  test("Document: invalid map", () {
    expect(document.getMap("boolInt"), null);
  });
  test("Document: invalid map", () {
    // ignore: deprecated_member_use_from_same_package
    expect(document.getArray("boolInt"), null);
  });
  test("Document: getting getKeys", () {
    expect(document.getKeys(), initializer!.keys);
  });
  test("Document: getting id", () {
    expect(document.id, "123456789");
  });
  test("mutableDocument: setting string", () {
    mutableDocument.setString('string', 'string');
    expect(mutableDocument.getString('string'), "string");
  });
  test("mutableDocument: setting double", () {
    mutableDocument.setDouble('double', 3.14);
    expect(mutableDocument.getDouble('double'), 3.14);
    expect(mutableDocument.getInt('double'), 3.14.toInt());
  });
  test("mutableDocument: setting int", () {
    mutableDocument.setInt('int', 12);
    expect(mutableDocument.getInt('int'), 12);
  });
  test("mutableDocument: setting map", () {
    mutableDocument.setMap('map', <String, dynamic>{"test": true});
    expect(mutableDocument.getMap('map'), {"test": true});
  });
  test("mutableDocument: setting list", () {
    // ignore: deprecated_member_use_from_same_package
    mutableDocument.setArray('list', <int>[]);
    // ignore: deprecated_member_use_from_same_package
    expect(mutableDocument.getArray('list'), []);
    mutableDocument.setList('list', <int>[]);
    expect(mutableDocument.getList('list'), []);
  });
  test("mutableDocument: null map", () {
    expect(mutableDocument.getMap("null"), null);
  });
  test("mutableDocument: null list", () {
    // ignore: deprecated_member_use_from_same_package
    expect(mutableDocument.getArray("null"), null);
    expect(mutableDocument.getList("null"), null);
  });
  test("mutableDocument: invalid list", () {
    expect(mutableDocument.getMap("boolInt"), null);
  });
  test("mutableDocument: invalid map", () {
    expect(mutableDocument.getList("boolInt"), null);
  });
  test("mutableDocument: to map", () {
    mutableDocument.setBoolean("bool", true);
    mutableDocument.setInt('int', 12);
    mutableDocument.remove('int');
    expect(mutableDocument.toMap(), {"bool": true});
  });
  test("mutableDocument: getting bool", () {
    mutableDocument.setBoolean("bool", true);
    expect(document.getBoolean("bool"), true);
  });
  test("mutableDocument: setting data / toMutable", () {
    var map = mutableDocument.toMap();
    mutableDocument.setData(null);
    expect(mutableDocument.toMap(), {});
    expect(mutableDocument.getKeys(), []);
    mutableDocument.setData(map);
    expect(mutableDocument.toMap(), map);
    expect(mutableDocument.toMutable().toMap(), map);
  });
  test("Blob", () async {
    Blob blob = Blob.data("application/octet-stream", Uint8List(0));
    mutableDocument.setBlob("blob", blob);
    expect(await mutableDocument.getBlob("blob")!.content, await blob.content);
  });
  test("NullDocument", () {
    expect(MutableDocument(id: "test").toMap(), {});
  });
}
