part of couchbase_lite;

class ResultSet extends Object with IterableMixin<Result> {
  ResultSet(List<Result> _list) {
    _internalState = _list;
  }

  late List<Result> _internalState;

  List<Result> allResults() => List.of(_internalState);

  @override
  Iterator<Result> get iterator => _internalState.iterator;
}
