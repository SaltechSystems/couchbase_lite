// Copyright 2020-present the Saltech Systems authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/foundation.dart';
import '../models/api/token_response.dart';
import 'package:http/http.dart' as http;
import 'repository.dart';

class ApiProvider {
  ApiProvider(this.client);

  static final ApiProvider instance = ApiProvider(http.Client());

  final http.Client client;
  final String devUrl = "https://dev.example.com";
  final prodUrl = "https://www.example.com";

  String get authEndpoint {
    return environment == Environment.development
        ? '$devUrl/oauth/v2/token'
        : '$prodUrl/oauth/v2/token';
  }

  @visibleForTesting
  String get apiEndpoint {
    return environment == Environment.development
        ? '$devUrl/api/v1'
        : '$prodUrl/api/v1';
  }

  @visibleForTesting
  String get clientID {
    return environment == Environment.development
        ? 'DEVELOPMENT_CLIENT_ID_GOES_HERE'
        : 'PRODUCTION_CLIENT_ID_GOES_HERE';
  }

  @visibleForTesting
  String get clientSecret {
    return environment == Environment.development
        ? 'DEVELOPMENT_CLIENT_SECRET_GOES_HERE'
        : 'PRODUCTION_CLIENT_ID_GOES_HERE';
  }

  // If refreshing the access token fails we will use this function to logout
  LogoutCallback _onLogout;
  @visibleForTesting
  String refreshToken = "";
  @visibleForTesting
  String accessToken = "";
  @visibleForTesting
  String tokenType = "";
  DateTime expiresAt = DateTime(0);
  @visibleForTesting
  Environment environment = Environment.production;

  Future<http.Response> login(String username, String password,
      {LogoutCallback onLogout}) async {
    _onLogout = onLogout;

    /*final response = await client.post(authEndpoint, body: {
      "grant_type": "password",
      "username": username,
      "password": password,
      "client_id": clientID,
      "client_secret": clientSecret
    });*/

    final tokenPreResponse = TokenResponse((b) => b
      ..accessToken = "accessToken"
      ..tokenType = "bearer"
      ..refreshToken = "refreshToken"
      ..expiresIn = 3600
      ..scope = "");

    final response = http.Response(tokenPreResponse.toJson(), 200);

    if (response.statusCode == 200) {
      var tokenResponse = TokenResponse.fromJson(response.body);
      accessToken = tokenResponse.accessToken;
      tokenType = tokenResponse.tokenType;
      refreshToken = tokenResponse.refreshToken;
      expiresAt =
          DateTime.now().add(Duration(seconds: tokenResponse.expiresIn));
    }

    return response;
  }

  @visibleForTesting
  Future<void> refreshAccessTokenIfNeeded() async {
    if (expiresAt.add(Duration(seconds: 1)).compareTo(DateTime.now()) < 0) {
      final response = await client.post(authEndpoint, body: {
        "grant_type": "refresh_token",
        "client_id": clientID,
        "refresh_token": refreshToken
      });

      if (response.statusCode == 200) {
        var tokenResponse = TokenResponse.fromJson(response.body);
        accessToken = tokenResponse.accessToken;
        tokenType = tokenResponse.tokenType;
        expiresAt =
            DateTime.now().add(Duration(seconds: tokenResponse.expiresIn));
      } else if (response.statusCode == 401 && _onLogout != null) {
        _onLogout(LogoutMethod.apiCredentialsError);
      }
    }
  }
}
