part of couchbase_lite;

/// Fragment provides readonly access to data value. Fragment also provides subscript access by
/// either key or index to the nested values which are wrapped by Fragment objects.
class Fragment {
  Fragment._init(dynamic value) {
    _value = value;
  }

  dynamic _value;

  /// Checks whether the value held by the fragment object exists or is nil value or not.
  bool get exists => _value != null;

  /// Gets a property's value as a boolean value.
  /// Returns true if the value exists, and is either `true` or a nonzero number.
  ///
  /// - Returns: The Bool value.
  bool? getBoolean() {
    if (_value is num) {
      return _value != 0;
    }

    return _value is bool ? _value : false;
  }

  /// Gets a property's value as a double value.
  /// Integers will be converted to double. The value `true` is returned as 1.0, `false` as 0.0.
  /// Returns 0.0 if the property doesn't exist or does not have a numeric value.
  ///
  /// - Returns: The Double value.
  double? getDouble() {
    if (_value is double) {
      return _value;
    } else if (_value is int) {
      return _value.toDouble();
    } else {
      return 0.0;
    }
  }

  /// Gets a property's value as an int value.
  /// Floating point values will be rounded. The value `true` is returned as 1, `false` as 0.
  /// Returns 0 if the property doesn't exist or does not have a numeric value.
  ///
  /// - Returns: The Int value.
  int? getInt() {
    if (_value is double) {
      return _value.toInt();
    } else if (_value is int) {
      return _value;
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
  /// - Returns: The Blob object or null.
  Blob? getBlob() {
    var result = getValue();
    if (result is Blob) {
      return result;
    } else {
      return null;
    }
  }

  ///  Gets a property's value as a string.
  ///  Returns null if the property doesn't exist, or its value is not a string.
  ///
  /// - Returns: The String object or null.
  String? getString() {
    return _value is String ? _value : null;
  }

  /// Gets a property's value. The value types are Blob, ArrayObject,
  /// DictionaryObject, Number, or String based on the underlying data type; or null
  /// if the value is null or the property doesn't exist.
  ///
  /// - Returns: The value or null.
  Object? getValue() {
    if (_value is Map) {
      if (_value['@type'] == 'blob') {
        return Blob._fromMap(_value);
      } else {
        return Map.from(_value);
      }
    } else if (_value is List) {
      return List.from(_value);
    } else {
      return _value;
    }
  }

  /// Get a property's value as a List Object, which is a mapping object of an array value.
  /// Returns null if the property doesn't exists, or its value is not an array.
  ///
  /// - Returns: The List Object object or null.
  List<T>? getList<T>() {
    var result = getValue();
    if (result is List) {
      return List.castFrom<dynamic, T>(result);
    }

    return null;
  }

  /// Get a property's value as a Map Object, which is a mapping object of
  /// a dictionary value.
  /// Returns null if the property doesn't exists, or its value is not a dictionary.
  ///
  /// - Returns: The Map Object object or nil.
  Map<K, V>? getMap<K, V>() {
    var result = getValue();
    if (result is Map) {
      return Map.castFrom<dynamic, dynamic, K, V>(result);
    }

    return null;
  }

  /// Subscript access to a Fragment object by key.
  Fragment operator [](dynamic key) {
    if (key is int && _value is List) {
      if (key < _value.length) {
        return Fragment._init(_value[key]);
      }
    } else if (key is String && _value is Map) {
      return Fragment._init(_value[key]);
    }

    return Fragment._init(null);
  }
}
