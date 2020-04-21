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

import 'dart:async';

import 'package:built_collection/src/list.dart';
import 'package:couchbase_lite_example/data/observable_response.dart';
import 'package:couchbase_lite_example/models/database/beer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'package:couchbase_lite_example/data/database.dart';
import 'package:couchbase_lite_example/data/repository.dart';
import 'package:couchbase_lite_example/data/api_provider.dart';

export 'database.dart';

enum Environment { development, production }
enum LoginResult { unauthorized, authorized, disconnected, error }
enum LogoutMethod {
  normal,
  apiCredentialsError,
  dbCredentialsError,
  validationError,
  sessionDeleted
}

enum ResponseCode {
  success,
  notFound,
  error,
}

typedef LogoutCallback = void Function(LogoutMethod method);

class RepoResponse<T> {
  RepoResponse({this.code, this.result}) : assert(code != null);

  final ResponseCode code;
  final T result;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RepoResponse &&
        other.code == this.code &&
        other.result == this.result;
  }
}

class ReceivedNotification {
  ReceivedNotification(
      {@required this.id,
      @required this.title,
      @required this.body,
      @required this.payload});

  final int id;
  final String title;
  final String body;
  final String payload;
}

class Repository {
  Repository._internal() {
    _database = AppDatabase.instance;
  }

  AppDatabase _database;

  static final Repository instance = Repository._internal();
  final _isLoggedInSubject = BehaviorSubject<bool>.seeded(false);
  final _lastLogoutMethodSubject =
      BehaviorSubject<LogoutMethod>.seeded(LogoutMethod.normal);

  Stream<bool> get isLoggedIn => _isLoggedInSubject.stream;
  Stream<LogoutMethod> get lastLogoutMethod => _lastLogoutMethodSubject.stream;

  Future<void> login(Environment environment, String username, String password,
      Function(LoginResult) callback) async {
    try {
      var response = await ApiProvider.instance
          .login(username, password, onLogout: triggerLogout);

      if (response.statusCode == 200) {
        var success = await _database.login(username, password);
        if (success) {
          callback(LoginResult.authorized);
          _isLoggedInSubject.add(true);
        } else {
          callback(LoginResult.error);
        }
      } else if (response.statusCode == 401) {
        callback(LoginResult.unauthorized);
      } else {
        callback(LoginResult.error);
      }
    } catch (e) {
      debugPrint(e);
      callback(LoginResult.disconnected);
    }
  }

  void triggerLogout(LogoutMethod method) {
    _isLoggedInSubject.add(false);
    _lastLogoutMethodSubject.add(method);
  }

  // Call this once all streams / listeners have been cleaned up ( Your homepage )
  Future<void> logout() async {
    await _database.logout();
  }

  void dispose() async {
    await _isLoggedInSubject.close();
    await _lastLogoutMethodSubject.close();
  }

  ObservableResponse<BuiltList<Beer>> getBeer(
          int limit, int offset, bool isDescending) =>
      _database.getBeer(limit, offset, isDescending);
}
