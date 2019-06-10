part of couchbase_lite;

/// Authenticator objects provide server authentication credentials to the replicator.
abstract class Authenticator {}

class BasicAuthenticator implements Authenticator {
  final String username;
  final String password;

  /// The BasicAuthenticator class is an authenticator that will authenticate using HTTP Basic auth with the given [username] and [password].
  BasicAuthenticator(this.username, this.password);

  Map<String, dynamic> toJson() {
    return {
      "method": "basic",
      "username": username,
      "password": password,
    };
  }
}

class SessionAuthenticator implements Authenticator {
  final String sessionId;
  final String cookieName;

  /// The SessionAuthenticator class is an authenticator that will authenticate by using the [sessionId] of the session created by a Sync Gateway.
  SessionAuthenticator(this.sessionId, {this.cookieName});

  Map<String, dynamic> toJson() {
    return {
      "method": "session",
      "sessionId": sessionId,
      "cookieName": cookieName,
    };
  }
}
