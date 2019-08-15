part of couchbase_lite;

/// Couchbase Lite document. The Document is immutable.
class Blob {
  Blob.data(this._contentType, this._data);

  Blob._fromMap(Map<String, dynamic> map) {
    this._contentType = map["contentType"];
    this._digest = map["digest"];
    this._length = map["length"];
  }

  String _dbname;
  String _documentID;
  String _documentKey;
  String _contentType;
  String _digest;
  int _length;
  Uint8List _data;
  bool _shouldLoadData = false;
  String get contentType => _contentType;
  String get digest => _digest;
  int get length => _length;
  Future<Uint8List> get content async {
    if (_shouldLoadData) {
      return await Database._methodChannel.invokeMethod(
          'getBlobContentFromDocumentWithId', <String, dynamic>{
        'database': _dbname,
        'id': _documentID,
        'key': _documentKey,
        'digest': _digest
      });
    } else {
      return _data;
    }
  }

  /// Gets content of the current object as a Dictionary.
  ///
  /// - Returns: The Dictionary representing the content of the current object.
  Map<String, dynamic> toMap() {
    return {"contentType": _contentType, "data": _data, "@type": "blob"};
  }
}
