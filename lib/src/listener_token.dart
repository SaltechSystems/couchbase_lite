part of couchbase_lite;

class ListenerToken {
  final tokenId = Uuid().v1();

  /// Listener token returned when adding a change listener. The token is used for removing the added change listener.
  ListenerToken();

  Map<String, dynamic> toJson() => {"token": tokenId};

  @override
  bool operator ==(other) {
    if (other is ListenerToken) {
      return tokenId == other.tokenId;
    }

    return false;
  }

  @override
  int get hashCode => tokenId.hashCode;
}
