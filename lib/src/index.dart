part of couchbase_lite;

abstract class Index {
  List<Map<String, dynamic>> toJson();
}

class ValueIndexItem {
  ValueIndexItem(this._map);

  /// Creates a ValueIndexItem for the given [property]
  factory ValueIndexItem.property(String property) {
    return ValueIndexItem({'property': property});
  }

  /// Creates a ValueIndexItem for the given [expression]
  factory ValueIndexItem.expression(Expression expression) {
    return ValueIndexItem({'expression': expression.toJson()});
  }

  Map<String, dynamic> _map;

  /// Returns the json representation of this object
  Map<String, dynamic> toJson() => _map;
}

class ValueIndex extends Index {
  ValueIndex(this._valueIndexItems);

  final List<ValueIndexItem> _valueIndexItems;

  @override
  List<Map<String, dynamic>> toJson() {
    var map = <Map<String, dynamic>>[];
    for (var item in _valueIndexItems) {
      map.add(item.toJson());
    }
    return map;
  }
}

class FullTextIndexItem {
  FullTextIndexItem(this._map);

  /// Creates a FullTextIndexItem for the given [property]
  factory FullTextIndexItem.property(String property) {
    return FullTextIndexItem({'property': property});
  }

  Map<String, dynamic> _map;

  /// Returns the json representation of this object
  Map<String, dynamic> toJson() => _map;
}

class FullTextIndex extends Index {
  FullTextIndex(this._fullTextIndexItems);

  final List<FullTextIndexItem> _fullTextIndexItems;
  bool? _ignoreAccents;
  String? _language;

  FullTextIndex ignoreAccents(bool ignoreAccents) {
    _ignoreAccents = ignoreAccents;
    return this;
  }

  FullTextIndex language(String language) {
    _language = language;
    return this;
  }

  @override
  List<Map<String, dynamic>> toJson() {
    var map = <Map<String, dynamic>>[];
    for (var item in _fullTextIndexItems) {
      map.add(item.toJson());
    }
    if (_ignoreAccents != null) {
      map.add({'ignoreAccents': _ignoreAccents});
    }
    if (_language != null) {
      map.add({'language': _language});
    }
    return map;
  }
}

class IndexBuilder {
  /// Creates a value index with the given index items. The index items are a list of the properties or expressions to be indexed.
  static ValueIndex valueIndex({required List<ValueIndexItem> items}) {
    return ValueIndex(items);
  }

  /// Creates a full-text index with the given index items. The index items are a list of the properties to be indexed.
  static FullTextIndex fullTextIndex({required List<FullTextIndexItem> items}) {
    return FullTextIndex(items);
  }
}
