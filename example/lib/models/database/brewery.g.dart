// GENERATED CODE - DO NOT MODIFY BY HAND

part of brewery;

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Brewery> _$brewerySerializer = new _$BrewerySerializer();

class _$BrewerySerializer implements StructuredSerializer<Brewery> {
  @override
  final Iterable<Type> types = const [Brewery, _$Brewery];
  @override
  final String wireName = 'Brewery';

  @override
  Iterable<Object> serialize(Serializers serializers, Brewery object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  Brewery deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new BreweryBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
      }
    }

    return result.build();
  }
}

class _$Brewery extends Brewery {
  @override
  final String id;
  @override
  final String name;

  factory _$Brewery([void Function(BreweryBuilder) updates]) =>
      (new BreweryBuilder()..update(updates)).build();

  _$Brewery._({this.id, this.name}) : super._() {
    if (name == null) {
      throw new BuiltValueNullFieldError('Brewery', 'name');
    }
  }

  @override
  Brewery rebuild(void Function(BreweryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BreweryBuilder toBuilder() => new BreweryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Brewery && id == other.id && name == other.name;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, id.hashCode), name.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Brewery')
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class BreweryBuilder implements Builder<Brewery, BreweryBuilder> {
  _$Brewery _$v;

  String _id;
  String get id => _$this._id;
  set id(String id) => _$this._id = id;

  String _name;
  String get name => _$this._name;
  set name(String name) => _$this._name = name;

  BreweryBuilder();

  BreweryBuilder get _$this {
    if (_$v != null) {
      _id = _$v.id;
      _name = _$v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Brewery other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Brewery;
  }

  @override
  void update(void Function(BreweryBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Brewery build() {
    final _$result = _$v ?? new _$Brewery._(id: id, name: name);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
