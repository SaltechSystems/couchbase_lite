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

library beer;

import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'serializers.dart';

part 'beer.g.dart';

abstract class Beer implements Built<Beer, BeerBuilder> {
  Beer._();

  factory Beer([updates(BeerBuilder b)]) = _$Beer;

  @BuiltValueField(wireName: 'beerID')
  String get beerID;
  @BuiltValueField(wireName: 'name')
  String get name;

  String toJson() {
    return json.encode(toMap());
  }

  Map toMap() {
    return standardSerializers.serializeWith(Beer.serializer, this);
  }

  static Beer fromJson(String jsonString) {
    return fromMap(json.decode(jsonString));
  }

  static Beer fromMap(Map jsonMap) {
    return standardSerializers.deserializeWith(Beer.serializer, jsonMap);
  }

  static Serializer<Beer> get serializer => _$beerSerializer;
}
