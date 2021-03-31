part of couchbase_lite;

class Result {
  final Map<String, dynamic> _internalMap = {};
  final List<dynamic> _internalList = [];
  final List<String> _keys = [];

  bool contains(String key) {
    return _internalMap.containsKey(key);
  }

  int count() {
    return _internalList.length;
  }

  List<dynamic>? getList({int? index, String? key}) {
    var result = getValue(index: index, key: key);
    if (result is List<dynamic>) {
      return result;
    } else {
      return null;
    }
  }

  Blob? getBlob({int? index, String? key}) {
    var result = getValue(index: index, key: key);
    if (result is Map && result['@type'] == 'blob') {
      return Blob._fromMap(result);
    } else {
      return null;
    }
  }

  bool? getBoolean({int? index, String? key}) {
    var result = getValue(index: index, key: key);
    if (result is bool) {
      return result;
    } else if (result is num) {
      return result != 0;
    } else {
      return null;
    }
  }

  //TODO: implement Date object and getDate

  double? getDouble({int? index, String? key}) {
    var result = getValue(index: index, key: key);
    if (result is double) {
      return result;
    } else {
      return null;
    }
  }

  int? getInt({int? index, String? key}) {
    var result = getValue(index: index, key: key);
    if (result is int) {
      return result;
    } else {
      return null;
    }
  }

  List<String> getKeys() {
    return _keys;
  }

  String? getString({int? index, String? key}) {
    var result = getValue(index: index, key: key);
    if (result is String) {
      return result;
    } else {
      return null;
    }
  }

  Object? getValue({int? index, String? key}) {
    if (null != index && _internalList.length > index) {
      return _internalList[index];
    } else if (null != key && _internalMap.containsKey(key)) {
      return _internalMap[key];
    } else {
      return null;
    }
  }

  //TODO: implement iterator()

  List<dynamic> toList() {
    return _internalList;
  }

  Map<String, dynamic> toMap() {
    return _internalMap;
  }

  Fragment operator [](dynamic key) {
    if (key is int) {
      if (key < _internalList.length) {
        return Fragment._init(_internalList[key]);
      }
    } else if (key is String) {
      return Fragment._init(_internalMap[key]);
    }

    return Fragment._init(null);
  }

  void setMap(Map<String, dynamic> map) {
    _internalMap.clear();
    _internalMap.addAll(map);
  }

  void setList(List<dynamic> list) {
    _internalList.clear();
    _internalList.addAll(list);
  }

  void setKeys(List<String> keys) {
    _keys.clear();
    _keys.addAll(keys);
  }
}
