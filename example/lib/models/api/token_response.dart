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

library token_response;

import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'serializers.dart';

part 'token_response.g.dart';

abstract class TokenResponse
    implements Built<TokenResponse, TokenResponseBuilder> {
  TokenResponse._();

  factory TokenResponse([updates(TokenResponseBuilder b)]) = _$TokenResponse;

  @BuiltValueField(wireName: 'access_token')
  String get accessToken;
  @nullable
  @BuiltValueField(wireName: 'refresh_token')
  String get refreshToken;
  @BuiltValueField(wireName: 'token_type')
  String get tokenType;
  @BuiltValueField(wireName: 'expires_in')
  int get expiresIn;
  @BuiltValueField(wireName: 'scope')
  String get scope;

  String toJson() {
    return json.encode(toMap());
  }

  Map toMap() {
    return standardSerializers.serializeWith(TokenResponse.serializer, this);
  }

  static TokenResponse fromJson(String jsonString) {
    return fromMap(json.decode(jsonString));
  }

  static TokenResponse fromMap(Map jsonMap) {
    return standardSerializers.deserializeWith(
        TokenResponse.serializer, jsonMap);
  }

  static Serializer<TokenResponse> get serializer => _$tokenResponseSerializer;
}
