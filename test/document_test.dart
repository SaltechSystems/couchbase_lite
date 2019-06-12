import 'package:flutter_test/flutter_test.dart';
import 'package:couchbase_lite/couchbase_lite.dart';

void main() {
  Document document;
  MutableDocument mutableDocument;
  setUp(() {
    var initializer = new Map();
    initializer['string'] = "string";
    initializer['double'] = 3.14;
    initializer['int'] = 12;
    document = Document(initializer, "123456789");
    mutableDocument = MutableDocument();
  });

  test("Document: getting string", () {
    expect(document.getString('string'), "string");
  });
  test("Document: getting double", () {
    expect(document.getDouble('double'), 3.14);
  });
  test("Document: getting int", () {
    expect(document.getInt('int'), 12);
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
  });
  test("mutableDocument: setting int", () {
    mutableDocument.setInt('int', 12);
    expect(mutableDocument.getInt('int'), 12);
  });
  test("mutableDocument: setting id", () {
    mutableDocument.id = "123456789";
    expect(mutableDocument.id, "123456789");
    expect(mutableDocument.toMutable().id, "123456789");
  });
}
