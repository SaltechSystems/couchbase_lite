part of couchbase_lite;

enum ReplicatorActivityLevel { busy, idle, offline, stopped, connecting }

class Replicator {
  Replicator(this.config) {
    //this.config._isLocked = true;
    _storingReplicator = _jsonChannel.invokeMethod('storeReplicator', this);
  }

  static const MethodChannel _methodChannel =
      MethodChannel('com.saltechsystems.couchbase_lite/replicator');
  static const JSONMethodCodec _jsonMethod = JSONMethodCodec();
  static const MethodChannel _jsonChannel =
      MethodChannel('com.saltechsystems.couchbase_lite/json', _jsonMethod);
  static const EventChannel _replicationEventChannel =
      EventChannel('com.saltechsystems.couchbase_lite/replicationEventChannel');
  static final Stream _replicationStream =
      _replicationEventChannel.receiveBroadcastStream();

  final replicatorId = Uuid().v1();
  Map<ListenerToken, StreamSubscription> tokens = {};

  final ReplicatorConfiguration config;
  Future<void>? _storingReplicator;

  /// Starts the replicator.
  ///
  /// The replicator runs asynchronously and will report its progress throuh the replicator change notification.
  Future<void> start() async {
    await _storingReplicator;

    await _methodChannel
        .invokeMethod('start', <String, dynamic>{'replicatorId': replicatorId});
  }

  /// Stops a running replicator.
  ///
  /// When the replicator actually stops, the replicator will change its status’s activity level to .stopped and the replicator change notification will be notified accordingly.
  Future<void> stop() async {
    await _storingReplicator;

    await _methodChannel
        .invokeMethod('stop', <String, dynamic>{'replicatorId': replicatorId});
  }

  /// Stops a running replicator.
  ///
  /// When the replicator actually stops, the replicator will change its status’s activity level to .stopped and the replicator change notification will be notified accordingly.
  Future<void> resetCheckpoint() async {
    await _storingReplicator;

    await _methodChannel.invokeMethod(
        'resetCheckpoint', <String, dynamic>{'replicatorId': replicatorId});
  }

  /// Adds a replicator change listener.
  ///
  /// Returns the listener token object for removing the listener.
  ListenerToken addChangeListener(Function(ReplicatorChange) callback) {
    var token = ListenerToken();
    tokens[token] = _replicationStream
        .where((data) => (data['replicator'] == replicatorId &&
            data['type'] == 'ReplicatorChange'))
        .listen((data) {
      var activity = ReplicatorStatus.activityFromString(data['activity']);
      String? error;
      if (data['error'] is String) {
        error = data['error'];
      }

      callback(
          ReplicatorChange(this, ReplicatorStatus._internal(activity, error)));
    });
    return token;
  }

  /// Adds a document replicator change listener.
  ///
  /// Returns the listener token object for removing the listener.
  ListenerToken addDocumentReplicationListener(
      Function(DocumentReplication) callback) {
    var token = ListenerToken();
    tokens[token] = _replicationStream
        .where((data) => ((data['replicator'] == replicatorId &&
            data['type'] == 'DocumentReplication')))
        .listen((data) {
      callback(DocumentReplication.fromMap(data)!
          .rebuild((b) => b..replicator = this));
    });
    return token;
  }

  /// Removes a change listener with the given listener token.
  Future<ListenerToken> removeChangeListener(ListenerToken token) async {
    var subscription = tokens.remove(token);

    if (subscription != null) {
      await subscription.cancel();
    }

    return token;
  }

  /// Removes change listeners and references on the Platform.  This should be called when finished with the replicator to prevent memory leaks.
  Future<void> dispose() async {
    for (var token in List.from(tokens.keys)) {
      await removeChangeListener(token);
    }

    await _storingReplicator;

    await _methodChannel.invokeMethod(
        'dispose', <String, dynamic>{'replicatorId': replicatorId});
  }

  Map<String, dynamic> toJson() {
    return {'replicatorId': replicatorId, 'config': config};
  }
}

class ReplicatorStatus {
  ReplicatorStatus._internal(this.activity, this.error);

  final ReplicatorActivityLevel? activity;
  final String? error;

  static ReplicatorActivityLevel? activityFromString(String? _status) {
    switch (_status) {
      case 'BUSY':
        return ReplicatorActivityLevel.busy;
        break;
      case 'IDLE':
        return ReplicatorActivityLevel.idle;
        break;
      case 'OFFLINE':
        return ReplicatorActivityLevel.offline;
        break;
      case 'STOPPED':
        return ReplicatorActivityLevel.stopped;
        break;
      case 'CONNECTING':
        return ReplicatorActivityLevel.connecting;
        break;
    }

    return null;
  }
}

class ReplicatorChange {
  ReplicatorChange(this.replicator, this.status);

  final Replicator replicator;
  final ReplicatorStatus status;
}
