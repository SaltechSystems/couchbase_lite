part of couchbase_lite;

class Join {
  Join._internal(String selector, String _dataSource, {String? as}) {
    if (as != null) {
      _internalStack.add({selector: _dataSource, 'as': as});
    } else {
      _internalStack.add({selector: _dataSource});
    }
  }

  factory Join.join(String _dataSource, {String? as}) {
    return Join._internal('join', _dataSource, as: as);
  }

  factory Join.crossJoin(String _dataSource, {String? as}) {
    return Join._internal('crossJoin', _dataSource, as: as);
  }

  factory Join.innerJoin(String _dataSource, {String? as}) {
    return Join._internal('innerJoin', _dataSource, as: as);
  }

  factory Join.leftJoin(String _dataSource, {String? as}) {
    return Join._internal('leftJoin', _dataSource, as: as);
  }

  factory Join.leftOuterJoin(String _dataSource, {String? as}) {
    return Join._internal('leftOuterJoin', _dataSource, as: as);
  }

  final List<Map<String, dynamic>> _internalStack = [];

  Join on(Expression _expression) {
    _internalStack.add({'on': _expression});
    return this;
  }

  List<Map<String, dynamic>> toJson() => _internalStack;
}
