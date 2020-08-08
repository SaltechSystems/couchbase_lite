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
  List<String> channels;
  List<dynamic> pushAttributeValuesFilter;
  String pushAttributeKeyFilter;
  List<dynamic> pullAttributeValuesFilter;
  String pullAttributeKeyFilter;
  Map headers;

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{'database': database.name, 'target': target};

    switch (replicatorType) {
      case ReplicatorType.pushAndPull:
        map['replicatorType'] = 'PUSH_AND_PULL';
        break;
      case ReplicatorType.push:
        map['replicatorType'] = 'PUSH';
        break;
      case ReplicatorType.pull:
        map['replicatorType'] = 'PULL';
        break;
    }

    if (pinnedServerCertificate != null) {
      map['pinnedServerCertificate'] = pinnedServerCertificate;
    }

    if (authenticator != null) {
      map['authenticator'] = authenticator;
    }

    if (continuous != null) {
      map['continuous'] = continuous;
    }

    if (channels != null) {
      map['channels'] = channels;
    }

    if (pushAttributeValuesFilter != null) {
      map['pushAttributeValuesFilter'] = pushAttributeValuesFilter;
    }

    if (pushAttributeKeyFilter != null) {
      map['pushAttributeKeyFilter'] = pushAttributeKeyFilter;
    }

    if (pullAttributeValuesFilter != null) {
      map['pullAttributeValuesFilter'] = pullAttributeValuesFilter;
    }

    if (pullAttributeKeyFilter != null) {
      map['pullAttributeKeyFilter'] = pullAttributeKeyFilter;
    }

    if (headers != null) {
      map['headers'] = headers;
    }

    return map;
  }
}
