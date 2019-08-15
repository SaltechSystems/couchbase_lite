library replicated_document;

import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'serializers.dart';

part 'replicated_document.g.dart';

abstract class ReplicatedDocument
    implements Built<ReplicatedDocument, ReplicatedDocumentBuilder> {
  ReplicatedDocument._();

  factory ReplicatedDocument([updates(ReplicatedDocumentBuilder b)]) =
      _$ReplicatedDocument;

  @BuiltValueField(wireName: 'document')
  String get id;
  @nullable
  @BuiltValueField(wireName: 'error')
  String get error;
  @BuiltValueField(wireName: 'flags')
  int get flags;

  String toJson() {
    return json.encode(toMap());
  }

  Map toMap() {
    return standardSerializers.serializeWith(
        ReplicatedDocument.serializer, this);
  }

  static ReplicatedDocument fromJson(String jsonString) {
    return fromMap(json.decode(jsonString));
  }

  static ReplicatedDocument fromMap(Map jsonMap) {
    return standardSerializers.deserializeWith(
        ReplicatedDocument.serializer, jsonMap);
  }

  static Serializer<ReplicatedDocument> get serializer =>
      _$replicatedDocumentSerializer;
}
