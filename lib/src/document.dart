part of couchbase_lite;

/// Couchbase Lite document. The Document is immutable.
class Document {
  Document._init(
      [Map<dynamic, dynamic> data, this._id, this._dbname, this._sequence]) {
    _data = _stringMapFromDynamic(data ?? {});
  }

  Map<dynamic, dynamic> _data;
  String _dbname;
  String _id;
  int _sequence;

  String get id => _id;
  int get sequence => _sequence;

  Map<String, dynamic> _stringMapFromDynamic(Map<dynamic, dynamic> _map) {
    return Map.castFrom<dynamic, dynamic, String, dynamic>(_map);
  }

  /// Tests whether a property exists or not.
  /// This can be less expensive than value(forKey:), because it does not have to allocate an
  /// object for the property value.
  ///
  /// - Parameter key: The key.
  /// - Returns: True of the property exists, otherwise false.
  bool contains(String key) {
    return _data.containsKey(key);
  }

  /// The number of properties in the document.
  int count() {
    return _data.length;
  }

  /// Gets a property's value as a boolean value.
  /// Returns true if the value exists, and is either `true` or a nonzero number.
  ///
  /// - Parameter key: The key.
  /// - Returns: The Bool value.
  bool getBoolean(String key) {
    Object _result = getValue(key);

    if (_result is num) {
      return _result != 0;
    }

    return _result is bool ? _result : false;
  }

  /// Gets a property's value as a double value.
  /// Integers will be converted to double. The value `true` is returned as 1.0, `false` as 0.0.
  /// Returns 0.0 if the property doesn't exist or does not have a numeric value.
  ///
  /// - Parameter key: The key.
  /// - Returns: The Double value.
  double getDouble(String key) {
    Object _result = getValue(key);
    if (_result is double) {
      return _result;
    } else if (_result is int) {
      return _result.toDouble();
    } else {
      return 0.0;
    }
  }

  /// Gets a property's value as an int value.
  /// Floating point values will be rounded. The value `true` is returned as 1, `false` as 0.
  /// Returns 0 if the property doesn't exist or does not have a numeric value.
  ///
  /// - Parameter key: The key.
  /// - Returns: The Int value.
  int getInt(String key) {
    Object _result = getValue(key);
    if (_result is double) {
      return _result.toInt();
    } else if (_result is int) {
      return _result;
    } else {
      return 0;
    }
  }

  ///  Get a property’s value as a Blob object without the data.
  ///  Returns nil if the property doesn’t exist, or its value is not a blob.
  ///  The blob content will not be stored in the blob, it will be fetched when accessed
  ///  and the content will return null when there is a discrepancy in the digest,
  ///  this can happen if the file updated since the last time the document was fetched.
  ///
  /// - Parameter key: The key.
  /// - Returns: The Blob object or null.
  Blob getBlob(String key) {
    Map<String, dynamic> _result = getMap(key);
    if (_result is Map && _result["@type"] == "blob") {
      if (_result.containsKey("data")) {
        return Blob.data(_result["contentType"], _result["data"]);
      } else {
        var _blob = Blob._fromMap(_result);
        _blob._dbname = _dbname;
        _blob._documentID = _id;
        _blob._documentKey = key;
        _blob._shouldLoadData = true;

        return _blob;
      }
    } else {
      return null;
    }
  }

  /// An array containing all keys, or an empty array if the document has no properties.
  List<String> getKeys() {
    return _data.keys.toList();
  }

  ///  Gets a property's value as a string.
  ///  Returns null if the property doesn't exist, or its value is not a string.
  ///
  /// - Parameter key: The key.
  /// - Returns: The String object or null.
  String getString(String key) {
    Object _result = getValue(key);
    return _result is String ? _result : null;
  }

  ///  Gets a property's value as a date.
  ///  Returns null if the property doesn't exist, or its value is not a date.
  ///
  /// - Parameter key: The key.
  /// - Returns: The DateTime object in UTC or null.
  /*DateTime _getDate(String key, DateTime value) {
    Object _result = getValue(key);
    return _result is String ? DateTime.parse(_result).toUtc() : null;
  }*/

  /// Gets a property's value. The value types are Blob, ArrayObject,
  /// DictionaryObject, Number, or String based on the underlying data type; or null
  /// if the value is null or the property doesn't exist.
  ///
  /// - Parameter key: The key.
  /// - Returns: The value or null.
  Object getValue(String key) {
    if (contains(key)) {
      return _data[key] as Object;
    } else {
      return null;
    }
  }

  /// Get a property's value as a List Object, which is a mapping object of an array value.
  /// Returns null if the property doesn't exists, or its value is not an array.
  ///
  /// - Parameter key: The key.
  /// - Returns: The List Object object or null.
  List<T> getList<T>(String key) {
    var _result = getValue(key);
    if (_result is List) {
      return List.from(List.castFrom<dynamic, T>(_result));
    }

    return null;
  }

  /// Get a property's value as a List Object, which is a mapping object of an array value.
  /// Returns null if the property doesn't exists, or its value is not an array.
  ///
  /// - Parameter key: The key.
  /// - Returns: The List Object object or null.
  @Deprecated('Use `getList`.')
  List<T> getArray<T>(String key) => getList(key);

  /// Get a property's value as a Map Object, which is a mapping object of
  /// a dictionary value.
  /// Returns null if the property doesn't exists, or its value is not a dictionary.
  ///
  /// - Parameter key: The key.
  /// - Returns: The Map Object object or nil.
  Map<K, V> getMap<K, V>(String key) {
    var _result = getValue(key);
    if (_result is Map) {
      return Map.from(Map.castFrom<dynamic, dynamic, K, V>(_result));
    }

    return null;
  }

  /// Gets content of the current object as a Dictionary.
  ///
  /// - Returns: The Dictionary representing the content of the current object.
  Map<String, dynamic> toMap() {
    return Map.from(_data);
  }

  /// Returns a mutable copy of the document.
  ///
  /// - Returns: The MutableDocument object.
  MutableDocument toMutable() {
    return MutableDocument._init(_data, id, _dbname, sequence);
  }
}
