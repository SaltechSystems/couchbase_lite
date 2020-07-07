part of couchbase_lite;

class Query {
  final queryId = Uuid().v1();
  bool _stored = false;
  Map<String, dynamic> _options = {};
  Parameters get parameters => throw UnimplementedError();
  Map<ListenerToken, StreamSubscription> tokens = {};

  Map<String, dynamic> get options => Map.from(_options);

  static const JSONMethodCodec _jsonMethod = JSONMethodCodec();
  static const MethodChannel _channel =
      MethodChannel('com.saltechsystems.couchbase_lite/json', _jsonMethod);
  static const EventChannel _queryEventChannel = EventChannel(
      "com.saltechsystems.couchbase_lite/queryEventChannel", _jsonMethod);
  static final Stream _stream = _queryEventChannel.receiveBroadcastStream();

  /// Executes the query.
  ///
  /// Returns the ResultSet object representing the query result.
  Future<ResultSet> execute() async {
    this._options["queryId"] = queryId;

    if (!_stored && tokens.isNotEmpty) {
      _stored = await _channel.invokeMethod('storeQuery', this);
    }

    try {
      final List<dynamic> resultSet =
          await _channel.invokeMethod('executeQuery', this);

      List<Result> results = List<Result>();
      for (dynamic result in resultSet) {
        Result newResult = Result();
        newResult.setMap(result["map"]);
        newResult.setList(result["list"]);
        results.add(newResult);
      }

      return ResultSet(results);
    } on PlatformException {
      // Remove all listeners on error
      for (var token in List.from(tokens.keys)) {
        await removeChangeListener(token);
      }

      rethrow;
    }
  }

  /// Adds a query change listener and posts changes to [callback].
  ///
  /// Returns the listener token object for removing the listener.
  Future<ListenerToken> addChangeListener(
      Function(QueryChange) callback) async {
    var token = ListenerToken();
    tokens[token] =
        _stream.where((data) => data["query"] == queryId).listen((data) {
      Map<String, dynamic> qcJson = data;
      final List<dynamic> resultList = qcJson["results"];

      ResultSet result;

      if (resultList != null) {
        List<Result> results = List<Result>();
        for (dynamic result in resultList) {
          Result newResult = Result();
          newResult.setMap(result["map"]);
          newResult.setList(result["list"]);
          results.add(newResult);
        }
        result = ResultSet(results);
      }

      String error = qcJson["error"];

      callback(QueryChange(query: this, results: result, error: error));
    });

    if (tokens[token] == null) {
      // Listener didn't subscribe to stream
      tokens.remove(token);
      return null;
    }

    return token;
  }

  /// Removes a change listener wih the given listener token.
  Future<void> removeChangeListener(ListenerToken token) async {
    final subscription = tokens.remove(token);

    if (subscription != null) {
      await subscription.cancel();
    }

    if (_stored && tokens.isEmpty) {
      // We had to store this before listening to so if stored on the platform
      _stored = !await _channel.invokeMethod('removeQuery', this);
    }
  }

  /// Returns a string describing the implementation of the compiled query.
  ///
  /// This is intended to be read by a developer for purposes of optimizing the query,
  /// especially to add database indexes. It’s not machine-readable and its format may change.
  /// As currently implemented, the result is two or more lines separated by newline characters:
  /// The first line is the SQLite SELECT statement.
  /// The subsequent lines are the output of SQLite’s “EXPLAIN QUERY PLAN” command
  /// applied to that statement;
  /// for help interpreting this, see https://www.sqlite.org/eqp.html .
  /// The most important thing to know is that if you see “SCAN TABLE”,
  /// it means that SQLite is doing a slow linear scan of the documents instead of using an index.
  ///
  Future<String> explain() {
    //Make sure the queryId is available when the toJson() method is called.
    this._options["queryId"] = queryId;
    return _channel.invokeMethod('explainQuery', this);
  }

  Map<String, dynamic> toJson() => this.options;
}

class QueryChange {
  QueryChange({this.query, this.results, this.error}) : assert(query != null);

  final Query query;
  final ResultSet results;
  final String error;
}
