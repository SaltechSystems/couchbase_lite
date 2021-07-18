// GENERATED CODE - DO NOT MODIFY BY HAND

part of replicated_document;

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<ReplicatedDocument> _$replicatedDocumentSerializer =
    new _$ReplicatedDocumentSerializer();

class _$ReplicatedDocumentSerializer
    implements StructuredSerializer<ReplicatedDocument> {
  @override
  final Iterable<Type> types = const [ReplicatedDocument, _$ReplicatedDocument];
  @override
  final String wireName = 'ReplicatedDocument';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, ReplicatedDocument object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'document',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'flags',
      serializers.serialize(object.flags, specifiedType: const FullType(int)),
    ];
    Object? value;
    value = object.error;
    if (value != null) {
      result
        ..add('error')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  ReplicatedDocument deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new ReplicatedDocumentBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'document':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'error':
          result.error = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'flags':
          result.flags = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
      }
    }

    return result.build();
  }
}

class _$ReplicatedDocument extends ReplicatedDocument {
  @override
  final String id;
  @override
  final String? error;
  @override
  final int flags;

  factory _$ReplicatedDocument(
          [void Function(ReplicatedDocumentBuilder)? updates]) =>
      (new ReplicatedDocumentBuilder()..update(updates)).build();

  _$ReplicatedDocument._({required this.id, this.error, required this.flags})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(id, 'ReplicatedDocument', 'id');
    BuiltValueNullFieldError.checkNotNull(flags, 'ReplicatedDocument', 'flags');
  }

  @override
  ReplicatedDocument rebuild(
          void Function(ReplicatedDocumentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReplicatedDocumentBuilder toBuilder() =>
      new ReplicatedDocumentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReplicatedDocument &&
        id == other.id &&
        error == other.error &&
        flags == other.flags;
  }

  @override
  int get hashCode {
    return $jf($jc($jc($jc(0, id.hashCode), error.hashCode), flags.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('ReplicatedDocument')
          ..add('id', id)
          ..add('error', error)
          ..add('flags', flags))
        .toString();
  }
}

class ReplicatedDocumentBuilder
    implements Builder<ReplicatedDocument, ReplicatedDocumentBuilder> {
  _$ReplicatedDocument? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  int? _flags;
  int? get flags => _$this._flags;
  set flags(int? flags) => _$this._flags = flags;

  ReplicatedDocumentBuilder();

  ReplicatedDocumentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _error = $v.error;
      _flags = $v.flags;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReplicatedDocument other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ReplicatedDocument;
  }

  @override
  void update(void Function(ReplicatedDocumentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$ReplicatedDocument build() {
    final _$result = _$v ??
        new _$ReplicatedDocument._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, 'ReplicatedDocument', 'id'),
            error: error,
            flags: BuiltValueNullFieldError.checkNotNull(
                flags, 'ReplicatedDocument', 'flags'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
