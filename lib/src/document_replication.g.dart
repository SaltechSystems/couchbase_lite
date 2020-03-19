// GENERATED CODE - DO NOT MODIFY BY HAND

part of document_replication;

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<DocumentReplication> _$documentReplicationSerializer =
    new _$DocumentReplicationSerializer();

class _$DocumentReplicationSerializer
    implements StructuredSerializer<DocumentReplication> {
  @override
  final Iterable<Type> types = const [
    DocumentReplication,
    _$DocumentReplication
  ];
  @override
  final String wireName = 'DocumentReplication';

  @override
  Iterable<Object> serialize(
      Serializers serializers, DocumentReplication object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'documents',
      serializers.serialize(object.documents,
          specifiedType: const FullType(
              BuiltList, const [const FullType(ReplicatedDocument)])),
    ];
    if (object.isPush != null) {
      result
        ..add('isPush')
        ..add(serializers.serialize(object.isPush,
            specifiedType: const FullType(bool)));
    }
    return result;
  }

  @override
  DocumentReplication deserialize(
      Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new DocumentReplicationBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'isPush':
          result.isPush = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool;
          break;
        case 'documents':
          result.documents.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(ReplicatedDocument)]))
              as BuiltList<Object>);
          break;
      }
    }

    return result.build();
  }
}

class _$DocumentReplication extends DocumentReplication {
  @override
  final Replicator replicator;
  @override
  final bool isPush;
  @override
  final BuiltList<ReplicatedDocument> documents;

  factory _$DocumentReplication(
          [void Function(DocumentReplicationBuilder) updates]) =>
      (new DocumentReplicationBuilder()..update(updates)).build();

  _$DocumentReplication._({this.replicator, this.isPush, this.documents})
      : super._() {
    if (documents == null) {
      throw new BuiltValueNullFieldError('DocumentReplication', 'documents');
    }
  }

  @override
  DocumentReplication rebuild(
          void Function(DocumentReplicationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DocumentReplicationBuilder toBuilder() =>
      new DocumentReplicationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DocumentReplication &&
        replicator == other.replicator &&
        isPush == other.isPush &&
        documents == other.documents;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc(0, replicator.hashCode), isPush.hashCode), documents.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('DocumentReplication')
          ..add('replicator', replicator)
          ..add('isPush', isPush)
          ..add('documents', documents))
        .toString();
  }
}

class DocumentReplicationBuilder
    implements Builder<DocumentReplication, DocumentReplicationBuilder> {
  _$DocumentReplication _$v;

  Replicator _replicator;
  Replicator get replicator => _$this._replicator;
  set replicator(Replicator replicator) => _$this._replicator = replicator;

  bool _isPush;
  bool get isPush => _$this._isPush;
  set isPush(bool isPush) => _$this._isPush = isPush;

  ListBuilder<ReplicatedDocument> _documents;
  ListBuilder<ReplicatedDocument> get documents =>
      _$this._documents ??= new ListBuilder<ReplicatedDocument>();
  set documents(ListBuilder<ReplicatedDocument> documents) =>
      _$this._documents = documents;

  DocumentReplicationBuilder();

  DocumentReplicationBuilder get _$this {
    if (_$v != null) {
      _replicator = _$v.replicator;
      _isPush = _$v.isPush;
      _documents = _$v.documents?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DocumentReplication other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$DocumentReplication;
  }

  @override
  void update(void Function(DocumentReplicationBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$DocumentReplication build() {
    _$DocumentReplication _$result;
    try {
      _$result = _$v ??
          new _$DocumentReplication._(
              replicator: replicator,
              isPush: isPush,
              documents: documents.build());
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'documents';
        documents.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'DocumentReplication', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
