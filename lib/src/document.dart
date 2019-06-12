part of couchbase_lite;

class Document {
  Map<dynamic, dynamic> _data;
  String _id;

  String get id => _id;

  Document([Map<dynamic, dynamic> data, String id]) {
    if (data != null) {
      _data = stringMapFromDynamic(data);
    } else {
      _data = Map<String, dynamic>();
    }

    _id = id;
  }

  Map<String, dynamic> stringMapFromDynamic(Map<dynamic, dynamic> _map) {
    return Map.castFrom<dynamic, dynamic, String, dynamic>(_map);
  }

  bool contains(String key) {
    if (_data != null && _data.isNotEmpty && _data.containsKey(key)) {
      return true;
    } else {
      return false;
    }
  }

  int count() {
    return _data.length;
  }

  bool getBoolean(String key) {
    Object _result = getValue(key);

    if (_result == 0 || _result == 1) {
      return _result == 1;
    }

    return _result is bool ? _result : null;
  }

  double getDouble(String key) {
    Object _result = getValue(key);
    if (_result is double) {
      return _result;
    } else if (_result is int) {
      return _result.toDouble();
    } else {
      return null;
    }
  }

  int getInt(String key) {
    Object _result = getValue(key);
    if (_result is double) {
      return _result.toInt();
    } else if (_result is int) {
      return _result;
    } else {
      return null;
    }
  }

  List<String> getKeys() {
    if (_data != null) {
      return _data.keys;
    } else {
      return List<String>();
    }
  }

  String getString(String key) {
    Object _result = getValue(key);
    return _result is String ? _result : "";
  }

  Object getValue(String key) {
    if (contains(key)) {
      return _data[key] as Object;
    } else {
      return null;
    }
  }

  List<T> getList<T>(String key) {
    List<dynamic> _result = getValue(key);
    if (_result != null) {
      return List.castFrom<dynamic, T>(_result);
    } else {
      return List<T>();
    }
  }

  Map<K, V> getMap<K, V>(String key) {
    Map<dynamic, dynamic> _result = getValue(key);
    if (_result != null) {
      return Map.castFrom<dynamic, dynamic, K, V>(_result);
    } else {
      return Map<K, V>();
    }
  }

  Map<String, dynamic> toMap() {
    return Map.of(_data);
  }

  MutableDocument toMutable() {
    return MutableDocument(_data, id);
  }
}
