library document_replication;

import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../couchbase_lite.dart';
import 'serializers.dart';

part 'document_replication.g.dart';

abstract class DocumentReplication
    implements Built<DocumentReplication, DocumentReplicationBuilder> {
  DocumentReplication._();

  factory DocumentReplication([updates(DocumentReplicationBuilder b)]) =
      _$DocumentReplication;

  @nullable
  @BuiltValueField(serialize: false)
  Replicator get replicator;
  @nullable
  @BuiltValueField(wireName: 'isPush')
  bool get isPush;
  @BuiltValueField(wireName: 'documents')
  BuiltList<ReplicatedDocument> get documents;

  String toJson() {
    return json.encode(toMap());
  }

  Map toMap() {
    return standardSerializers.serializeWith(
        DocumentReplication.serializer, this);
  }

  static DocumentReplication fromJson(String jsonString) {
    return fromMap(json.decode(jsonString));
  }

  static DocumentReplication fromMap(Map jsonMap) {
    return standardSerializers.deserializeWith(
        DocumentReplication.serializer, jsonMap);
  }

  static Serializer<DocumentReplication> get serializer =>
      _$documentReplicationSerializer;
}
