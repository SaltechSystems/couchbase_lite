part of couchbase_lite;

class Result {
  Result();

  Result.fromMap(Map<String, dynamic> map) {
    this._internalMap = map ?? {};
  }

  Map<String, dynamic> _internalMap = {};
  List<dynamic> _internalList = [];

  bool contains(String key) {
    if (_internalMap != null) {
      return _internalMap.containsKey(key);
    } else if (_internalList != null) {
      return _internalList.contains(key);
    } else {
      return null;
    }
  }

  int count() {
    var result;
    if (null != _internalMap) {
      result = _internalMap.length;
    } else if (null != _internalList) {
      result = _internalList.length;
    }
    return result;
  }

  List<dynamic> getList({int index, String key}) {
    var result = getValue(index: index, key: key);
    if (result is List<dynamic>) {
      return result;
    } else {
      return null;
    }
  }

  Blob getBlob({
    int index,
    @required String key,
    String dbName,
    String documentId,
  }) {
    var result = getValue(index: index, key: key);
    if (null != result) {
      return Blob.fromMap(
        result,
        dbName: dbName,
        documentId: documentId,
        key: key,
      );
    } else {
      return null;
    }
  }

  bool getBoolean({int index, String key}) {
    var result = getValue(index: index, key: key);
    if (result is bool) {
      return result;
    } else {
      return null;
    }
  }

  //TODO: implement Date object and getDate

  double getDouble({int index, String key}) {
    var result = getValue(index: index, key: key);
    if (result is double) {
      return result;
    } else {
      return null;
    }
  }

  int getInt({int index, String key}) {
    var result = getValue(index: index, key: key);
    if (result is int) {
      return result;
    } else {
      return null;
    }
  }

  List<String> getKeys() {
    if (null != _internalMap && _internalMap.isNotEmpty) {
      return List.unmodifiable(_internalMap.keys);
    } else {
      return null;
    }
  }

  String getString({int index, String key}) {
    var result = getValue(index: index, key: key);
    if (result is String) {
      return result;
    } else {
      return null;
    }
  }

  Object getValue({int index, String key}) {
    var result;
    if (null != index && null == key) {
      if (_internalList.length > index) {
        result = _internalList[index];
      }
    }
    if (null != key && null == index) {
      if (_internalMap.containsKey(key)) {
        result = _internalMap[key];
      }
    }
    return result;
  }

  //TODO: implement iterator()

  List<dynamic> toList() {
    return _internalList;
  }

  Map<String, dynamic> toMap() {
    return _internalMap;
  }

  void setMap(Map<String, dynamic> map) {
    _internalMap.clear();
    _internalMap.addAll(map);
  }

  void setList(List<dynamic> list) {
    _internalList.clear();
    _internalList.addAll(list);
  }
}
