part of couchbase_lite;

/// Couchbase Lite document. The Document is immutable.
class Blob {
  Blob.fromData(
    this.contentType,
    this._data, {
    this.dbName,
    this.documentId,
    this.key,
  });

  Blob.fromMap(
    Map<String, dynamic> map, {
    this.dbName,
    this.documentId,
    this.key,
  }) {
    contentType = map["content_type"];
    digest = map["digest"];
    length = map["length"];
  }

  @Deprecated('Use Blob.fromData instead. ')
  Blob.data(this.contentType, this._data);

  @Deprecated('Use Blob.fromMap instead. ')
  Blob._fromMap(Map<String, dynamic> map) {
    contentType = map["content_type"];
    digest = map["digest"];
    length = map["length"];
  }

  String dbName;
  String documentId;
  String key;

  String contentType;
  String digest;
  int length;
  Uint8List _data;

  Future<Uint8List> get content async {
    _data ??= await Database._methodChannel.invokeMethod(
      'getBlobContentFromDocumentWithId',
      <String, dynamic>{
        'database': dbName,
        'id': documentId,
        'key': key,
        'digest': digest
      },
    );

    return _data;
  }

  /// Gets content of the current object as a Dictionary.
  ///
  /// - Returns: The Dictionary representing the content of the current object.
  Map<String, dynamic> toMap() {
    return {
      "content_type": contentType,
      "data": _data,
      "@type": "blob",
    };
  }
}
