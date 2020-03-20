part of couchbase_lite;

class MutableDocument extends Document {
  MutableDocument({String id, Map<dynamic, dynamic> data})
      : super._init(data, id);

  MutableDocument._init(
      [Map<dynamic, dynamic> data, String id, String dbname, int sequence])
      : super._init(data, id, dbname, sequence);

  /// Set a value for the given key. Allowed value types are List, Map,
  /// Int, Double, Boolean, and String.
  /// The Lists and Maps must contain only the above types.
  ///
  /// - Parameters:
  ///   - value: The value.
  ///   - key: The key.
  /// - Returns: The self object.
  MutableDocument setValue(String key, Object value) {
    if (value != null) {
      super._data[key] = value;
    }

    return this;
  }

  /// Set a List object for the given key. Allowed value types are List, Map,
  /// Int, Double, Boolean, and String.
  ///
  /// - Parameters:
  ///   - value: The List object.
  ///   - key: The key.
  MutableDocument setList(String key, List<dynamic> value) =>
      setValue(key, value);

  /// Set a List object for the given key. Allowed value types are List, Map,
  /// Int, Double, Boolean, and String.
  ///
  /// - Parameters:
  ///   - value: The List object.
  ///   - key: The key.
  @Deprecated('Use `setList`.')
  MutableDocument setArray(String key, List<dynamic> value) =>
      setList(key, value);

  /// Set a Map Object object for the given key. Allowed value types are List, Map,
  /// Int, Double, Boolean, and String.
  ///
  /// - Parameters:
  ///   - value: The Map object.
  ///   - key: The key.
  MutableDocument setMap(String key, Map<dynamic, dynamic> value) =>
      setValue(key, value);

  /// Set a Blob object for the given key.
  ///
  /// - Parameters:
  ///   - value: The Blob object.
  ///   - key: The key.
  MutableDocument setBlob(String key, Blob value) =>
      setValue(key, value.toMap());

  /// Set a boolean value for the given key.
  ///
  /// - Parameters:
  ///   - value: The boolean value.
  ///   - key: The key.
  MutableDocument setBoolean(String key, bool value) => setValue(key, value);

  /// Set a double value for the given key.
  ///
  /// - Parameters:
  ///   - value: The double value.
  ///   - key: The key.
  MutableDocument setDouble(String key, double value) => setValue(key, value);

  /// Set an int value for the given key.
  ///
  /// - Parameters:
  ///   - value: The int value.
  ///   - key: The key.
  MutableDocument setInt(String key, int value) => setValue(key, value);

  /// Set a String value for the given key.
  ///
  /// - Parameters:
  ///   - value: The String value.
  ///   - key: The Document object.
  MutableDocument setString(String key, String value) => setValue(key, value);

  /// Set a Date value for the given key.
  ///
  /// - Parameters:
  ///   - value: The UTC DateTime value.
  ///   - key: The Document object.
  /*MutableDocument _setDate(String key, DateTime value) {
    if (!(value?.isUtc ?? true)) {
      throw ArgumentError.value(value, 'value', 'Must be in utc time.');
    }

    return setValue(key, value?.toIso8601String());
  }*/

  /// Removes a given key and its value.
  ///
  /// - Parameter key: The key.
  MutableDocument remove(String key) {
    super._data.remove(key);

    return this;
  }

  /// Set data for the document. Allowed value types are List, Map,
  /// Int, Double, Boolean, and String.
  /// The Lists and Maps must contain only the above types.
  ///
  /// - Parameters:
  ///   - value: The DateTime value.
  ///   - key: The Document object.
  MutableDocument setData(Map<String, dynamic> data) {
    super._data = _stringMapFromDynamic(data ?? {});

    return this;
  }

  /// Returns the same MutableDocument object.
  ///
  /// - Returns: The MutableDocument object.
  @override
  MutableDocument toMutable() {
    return MutableDocument._init(
        this.toMap(), this.id, this._dbname, this.sequence);
  }

  /// Get a property's value as a List Object, which is a mapping object of an array value.
  /// Returns null if the property doesn't exists, or its value is not an array.
  ///
  /// - Parameter key: The key.
  /// - Returns: The List Object object or null.
  @override
  List<T> getList<T>(String key) {
    var _result = getValue(key);
    if (_result is List) {
      return List.castFrom<dynamic, T>(_result);
    }

    return null;
  }

  /// Get a property's value as a Map Object, which is a mapping object of
  /// a dictionary value.
  /// Returns nil if the property doesn't exists, or its value is not a dictionary.
  ///
  /// - Parameter key: The key.
  /// - Returns: The Map Object object or nil.
  @override
  Map<K, V> getMap<K, V>(String key) {
    var _result = getValue(key);
    if (_result is Map) {
      return Map.castFrom<dynamic, dynamic, K, V>(_result);
    }

    return null;
  }
}
