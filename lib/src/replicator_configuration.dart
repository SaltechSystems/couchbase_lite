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

    return map;
  }
}
