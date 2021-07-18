// GENERATED CODE - DO NOT MODIFY BY HAND

part of beer;

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Beer> _$beerSerializer = new _$BeerSerializer();

class _$BeerSerializer implements StructuredSerializer<Beer> {
  @override
  final Iterable<Type> types = const [Beer, _$Beer];
  @override
  final String wireName = 'Beer';

  @override
  Iterable<Object?> serialize(Serializers serializers, Beer object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.beerID;
    if (value != null) {
      result
        ..add('beerID')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.name;
    if (value != null) {
      result
        ..add('name')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  Beer deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new BeerBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'beerID':
          result.beerID = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$Beer extends Beer {
  @override
  final String? beerID;
  @override
  final String? name;

  factory _$Beer([void Function(BeerBuilder)? updates]) =>
      (new BeerBuilder()..update(updates)).build();

  _$Beer._({this.beerID, this.name}) : super._();

  @override
  Beer rebuild(void Function(BeerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BeerBuilder toBuilder() => new BeerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Beer && beerID == other.beerID && name == other.name;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, beerID.hashCode), name.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Beer')
          ..add('beerID', beerID)
          ..add('name', name))
        .toString();
  }
}

class BeerBuilder implements Builder<Beer, BeerBuilder> {
  _$Beer? _$v;

  String? _beerID;
  String? get beerID => _$this._beerID;
  set beerID(String? beerID) => _$this._beerID = beerID;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  BeerBuilder();

  BeerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _beerID = $v.beerID;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Beer other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Beer;
  }

  @override
  void update(void Function(BeerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Beer build() {
    final _$result = _$v ?? new _$Beer._(beerID: beerID, name: name);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
