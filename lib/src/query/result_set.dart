part of couchbase_lite;

class ResultSet extends Object with IterableMixin<Result> {
  List<Result> _internalState;

  ResultSet(List<Result> _list) {
    this._internalState = _list;
  }

  List<Result> allResults() => List.of(_internalState);

  Iterator<Result> get iterator => _internalState.iterator;
}
