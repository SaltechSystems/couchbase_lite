import 'database.dart';
import 'authenticator.dart';

enum ReplicatorType { pushAndPull, push, pull }

class ReplicatorConfiguration {
  final Database database;
  final String target;
  ReplicatorType replicatorType = ReplicatorType.pushAndPull;
  bool continuous = false;
  String pinnedServerCertificate;
  Authenticator authenticator;

  ReplicatorConfiguration(this.database, this.target);

  Map<String, dynamic> toJson() {
    String replicatorTypeString;
    switch (replicatorType) {
      case ReplicatorType.pushAndPull:
        replicatorTypeString = "PUSH_AND_PULL";
        break;
      case ReplicatorType.push:
        replicatorTypeString = "PUSH";
        break;
      case ReplicatorType.pull:
        replicatorTypeString = "PULL";
        break;
    }

    return {
      "database": database.name,
      "target": target,
      "replicatorType": replicatorTypeString,
      "continuous": continuous,
      "pinnedServerCertificate": pinnedServerCertificate,
      "authenticator": authenticator,
    };
  }
}
