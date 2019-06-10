
abstract class Authenticator {

}

class BasicAuthenticator implements Authenticator {
  final String username;
  final String password;

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

  SessionAuthenticator(this.sessionId,{this.cookieName});

  Map<String, dynamic> toJson() {
    return {
      "method": "session",
      "sessionId": sessionId,
      "cookieName": cookieName,
    };
  }
}