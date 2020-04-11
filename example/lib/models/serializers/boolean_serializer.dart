// Copyright (c) 2018, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';

/// Alternative serializer for [DateTime].
///
/// Install this to use ISO8601 format instead of the default (microseconds
/// since epoch). Use [SerializersBuilder.add] to install it.
///
/// An exception will be thrown on attempt to serialize local DateTime
/// instances; you must use UTC.
class BooleanSerializer implements PrimitiveSerializer<bool> {
  final bool structured = false;
  @override
  final Iterable<Type> types = BuiltList<Type>([bool]);
  @override
  final String wireName = 'bool';

  @override
  Object serialize(Serializers serializers, bool value,
      {FullType specifiedType = FullType.unspecified}) {
    return value;
  }

  @override
  bool deserialize(Serializers serializers, Object serialized,
      {FullType specifiedType = FullType.unspecified}) {
    if (serialized is bool) {
      return serialized;
    } else if (serialized is int) {
      if (serialized == 1) {
        return true;
      } else if (serialized == 0) {
        return false;
      }
    }

    throw ArgumentError.value(
        serialized, 'serialized', 'Must be true, false, 0, or 1.');
  }
}
