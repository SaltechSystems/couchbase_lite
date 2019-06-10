import 'dart:async';
import 'package:flutter/services.dart';

import "document.dart";

class Database {
  static const MethodChannel _methodChannel =
      const MethodChannel('com.saltechsystems.couchbase_lite/database');

  final String name;

  Future<int> get count => _methodChannel
      .invokeMethod('getDocumentCount', <String, dynamic>{'database': name});

  Database._internal(this.name);

  static Future<Database> initWithName(String _name) async {
    await _methodChannel.invokeMethod(
        'initDatabaseWithName', <String, dynamic>{'database': _name});
    return Database._internal(_name);
  }

  static Future<void> deleteWithName(String _name) =>
      _methodChannel.invokeMethod(
          'deleteDatabaseWithName', <String, dynamic>{'database': _name});

  Future<Map<dynamic, dynamic>> documentWithId(String _id) =>
      _methodChannel.invokeMethod(
          'getDocumentWithId', <String, dynamic>{'database': name, 'id': _id});

  Future<String> saveDocument(Document _doc) => _methodChannel.invokeMethod(
      'saveDocument', <String, dynamic>{'database': name, 'map': _doc.toMap()});

  Future<String> saveDocumentWithId(String _id, Document _doc) =>
      _methodChannel.invokeMethod('saveDocumentWithId',
          <String, dynamic>{'database': name, 'id': _id, 'map': _doc.toMap()});

  Future<void> deleteDocument(String _id) => _methodChannel.invokeMethod(
      'deleteDocumentWithId', <String, dynamic>{'database': name, 'id': _id});

  Future<void> close() => _methodChannel.invokeMethod(
      'closeDatabaseWithName', <String, dynamic>{'database': name});

  //Not including this way of deleting for now because I remove the reference when we close the database
  //Future<void> delete() => _methodChannel.invokeMethod('delete', <String, dynamic>{'database': name});
}
