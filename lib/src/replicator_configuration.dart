part of couchbase_lite;

enum ReplicatorType { pushAndPull, push, pull }

class ReplicatorConfiguration {
  ReplicatorConfiguration(this.database, this.target);

  final Database database;
  final String target;
  ReplicatorType replicatorType = ReplicatorType.pushAndPull;
  bool? continuous;
  String? pinnedServerCertificate;
  Authenticator? authenticator;
  List<String>? channels;
  /// Filters which documents should be replicated. Keys are attribute names,
  /// and values are a list of allowed values for that attribute. A document
  /// will only be pushed if it matches all of the filters in this map.
  Map<String, List<dynamic>>? pushAttributeFilters;
  @Deprecated('use pushAttributeFilters instead for multiple filter support')
  List<dynamic>? pushAttributeValuesFilter;
  @Deprecated('use pushAttributeFilters instead for multiple filter support')
  String? pushAttributeKeyFilter;
  /// Filters which documents should be replicated. Keys are attribute names,
  /// and values are a list of allowed values for that attribute. A document
  /// will only be pulled if it matches all of the filters in this map.
  Map<String, List<dynamic>>? pullAttributeFilters;
  @Deprecated('use pullAttributeFilters instead for multiple filter support')
  List<dynamic>? pullAttributeValuesFilter;
  @Deprecated('use pullAttributeFilters instead for multiple filter support')
  String? pullAttributeKeyFilter;
  Map? headers;

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

    if (pushAttributeKeyFilter != null && pushAttributeValuesFilter != null) {
      pushAttributeFilters ??= {};
      pushAttributeFilters![pushAttributeKeyFilter!] = pushAttributeValuesFilter!;
    }

    if (pushAttributeFilters != null) {
      map['pushAttributeFilters'] = pushAttributeFilters;
    }

    if (pullAttributeKeyFilter != null && pullAttributeValuesFilter != null) {
      pullAttributeFilters ??= {};
      pullAttributeFilters![pullAttributeKeyFilter!] = pullAttributeValuesFilter!;
    }

    if (pullAttributeFilters != null) {
      map['pullAttributeFilters'] = pullAttributeFilters;
    }

    if (headers != null) {
      map['headers'] = headers;
    }

    return map;
  }
}
