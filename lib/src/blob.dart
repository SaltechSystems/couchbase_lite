part of couchbase_lite;

/// Couchbase Lite blob. The Blob is immutable.
class Blob {
  Blob.data(this._contentType, this._data);

  Blob._fromMap(Map<String, dynamic> map) {
    _contentType = map['content_type'];
    _digest = map['digest'];
    _length = map['length'];
    _data = map['data'];
  }

  String _contentType;
  String _digest;
  int _length;
  Uint8List _data;
  String get contentType => _contentType;
  String get digest => _digest;
  int get length => _length;

  Uint8List get blobData => _data;
  void set blobData(Uint8List data) => _data = data;

  Future<Uint8List> get content async {
    // Load data here if needed
    _data ??= await Database._methodChannel.invokeMethod(
        'getBlobContentWithDigest', <String, dynamic>{'digest': _digest});

    return _data;
  }

  /// Gets content of the current object as a Dictionary.
  ///
  /// - Returns: The Dictionary representing the content of the current object.
  Map<String, dynamic> toMap() {
    return {
      'content_type': _contentType,
      'digest': _digest,
      'length': _length,
      'data': _data,
      '@type': 'blob'
    };
  }
}
