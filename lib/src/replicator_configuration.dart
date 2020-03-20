part of couchbase_lite;

enum ReplicatorType { pushAndPull, push, pull }

class ReplicatorConfiguration {
  ReplicatorConfiguration(this.database, this.target);

  final Database database;
  final String target;
  ReplicatorType replicatorType = ReplicatorType.pushAndPull;
  bool continuous;
  String pinnedServerCertificate;
  Authenticator authenticator;

  /*bool Function(Document, int) _pushFilter;
  bool Function(Document, int) get pushFilter => _pushFilter;
  void set pushFilter(bool Function(Document, int) callback) {
    if (_isLocked) {
      throw StateError("Push Filter is in use by a replicator");
    } else {
      _pushFilter = callback;
    }
  }

  bool Function(Document, int) _pullFilter;
  bool Function(Document, int) get pullFilter => _pullFilter;
  void set pullFilter(bool Function(Document, int) callback) {
    if (_isLocked) {
      throw StateError("Pull Filter is in use by a replicator");
    } else {
      _pullFilter = callback;
    }
  }

  bool _isLocked = false;*/

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {"database": database.name, "target": target};

    switch (replicatorType) {
      case ReplicatorType.pushAndPull:
        map["replicatorType"] = "PUSH_AND_PULL";
        break;
      case ReplicatorType.push:
        map["replicatorType"] = "PUSH";
        break;
      case ReplicatorType.pull:
        map["replicatorType"] = "PULL";
        break;
    }

    if (pinnedServerCertificate != null) {
      map["pinnedServerCertificate"] = pinnedServerCertificate;
    }

    if (authenticator != null) {
      map["authenticator"] = authenticator;
    }

    if (continuous != null) {
      map["continuous"] = continuous;
    }

    //map["hasPushFilter"] = pushFilter != null;
    //map["hasPullFilter"] = pullFilter != null;

    return map;
  }
}
