part of couchbase_lite;

/// Couchbase Lite document. The Document is immutable.
class Blob {
  Blob.data(this._contentType, this._data);

  Blob._fromMap(Map<String, dynamic> map) {
    _contentType = map['content_type'];
    _digest = map['digest'];
    _length = map['length'];
    _data = map['data'];

    // Load the data when a blob is created
    if (_data == null) {
      // Load data here (JSONMethodCodec doesn't support data types used by Queries)
      _futureData = Database._methodChannel.invokeMethod(
        'getBlobContentWithDigest', <String, dynamic>{
          'digest': _digest
        });

      _futureData.then((value) {
        _data = value;
        _futureData = null;
      }).catchError((e) {
        print(e);
        return null;
      });
    }
  }

  String _contentType;
  String _digest;
  int _length;
  Uint8List _data;
  Future<Uint8List> _futureData;
  String get contentType => _contentType;
  String get digest => _digest;
  int get length => _length;
  Future<Uint8List> get content async {
    return _data ?? _futureData;
  }

  /// Gets content of the current object as a Dictionary.
  ///
  /// - Returns: The Dictionary representing the content of the current object.
  Map<String, dynamic> toMap() {
    return {"content_type": _contentType, "digest": _digest, "length": _length, "data": _data, "@type": "blob"};
  }
}
