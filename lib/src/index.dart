part of couchbase_lite;

class ValueIndexItem {
  Map<String, dynamic> _map;

  /// Returns the json representation of this object
  Map<String, dynamic> toJson() => _map;

  ValueIndexItem(this._map);

  /// Creates a ValueIndexItem for the given [property]
  factory ValueIndexItem.property(String property) {
    return ValueIndexItem({'property': property});
  }

  /// Creates a ValueIndexItem for the given [expression]
  factory ValueIndexItem.expression(Expression expression) {
    return ValueIndexItem({'expression': expression.toJson()});
  }
}

class ValueIndex {
  final List<ValueIndexItem> _valueIndexItems;

  ValueIndex(this._valueIndexItems);

  List<Map<String, dynamic>> toJson() {
    List<Map<String, dynamic>> map = [];
    for (var item in _valueIndexItems) {
      map.add(item.toJson());
    }
    return map;
  }
}

class IndexBuilder {
  /// Creates a value index with the given index items. The index items are a list of the properties or expressions to be indexed.
  static ValueIndex valueIndex({@required List<ValueIndexItem> items}) {
    return ValueIndex(items);
  }
}
