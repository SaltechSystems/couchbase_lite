part of couchbase_lite;

class Database {
  Database._internal(this.name);

  static const MethodChannel _methodChannel =
      const MethodChannel('com.saltechsystems.couchbase_lite/database');

  /// Initializes a Couchbase Lite database with the given [dbName].
  static Future<Database> initWithName(String dbName) async {
    await _methodChannel.invokeMethod(
        'initDatabaseWithName', <String, dynamic>{'database': dbName});
    return Database._internal(dbName);
  }

  final String name;

  Future<int> get count => _methodChannel
      .invokeMethod('getDocumentCount', <String, dynamic>{'database': name});

  /// Deletes a database of the given [dbName].
  static Future<void> deleteWithName(String dbName) =>
      _methodChannel.invokeMethod(
          'deleteDatabaseWithName', <String, dynamic>{'database': dbName});

  /// Gets a Document object with the given [id]
  Future<Document> documentWithId(String id) async {
    Map<dynamic, dynamic> _docResult = await _methodChannel.invokeMethod(
        'getDocumentWithId', <String, dynamic>{'database': name, 'id': id});

    return Document(_docResult["doc"], _docResult["id"]);
  }

  /// Saves a document to the database. When write operations are executed concurrently, the last writer will overwrite all other written values.
  Future<void> save(MutableDocument doc) async {
    if (doc.id == null) {
      doc.id = await _methodChannel.invokeMethod('saveDocument',
          <String, dynamic>{'database': name, 'map': doc.toMap()});
    } else {
      doc.id = await _methodChannel.invokeMethod(
          'saveDocumentWithId', <String, dynamic>{
        'database': name,
        'id': doc.id,
        'map': doc.toMap()
      });
    }
  }

  /// Saves [doc] to the database with the document id set by the database.
  @Deprecated('Use `save` instead.')
  Future<String> saveDocument(Document doc) {
    if (doc.id == null) {
      return _methodChannel.invokeMethod('saveDocument',
          <String, dynamic>{'database': name, 'map': doc.toMap()});
    } else {
      return _methodChannel.invokeMethod(
          'saveDocumentWithId', <String, dynamic>{
        'database': name,
        'id': doc.id,
        'map': doc.toMap()
      });
    }
  }

  /// Saves [doc] to the database with the Document id set to [id].
  @Deprecated('Use `save` instead.')
  Future<String> saveDocumentWithId(String id, Document doc) =>
      _methodChannel.invokeMethod('saveDocumentWithId',
          <String, dynamic>{'database': name, 'id': id, 'map': doc.toMap()});

  /// Deletes document with [id] from the database.
  Future<void> deleteDocument(String id) => _methodChannel.invokeMethod(
      'deleteDocumentWithId', <String, dynamic>{'database': name, 'id': id});

  /// Closes database.
  Future<void> close() => _methodChannel.invokeMethod(
      'closeDatabaseWithName', <String, dynamic>{'database': name});

  //Not including this way of deleting for now because I remove the reference when we close the database
  //Future<void> delete() => _methodChannel.invokeMethod('delete', <String, dynamic>{'database': name});

  //Not including this way of disposing for now because I remove the reference when we close the database
  //Future<void> dispose() => _methodChannel.invokeMethod('dispose', <String, dynamic>{'database': name});
}
