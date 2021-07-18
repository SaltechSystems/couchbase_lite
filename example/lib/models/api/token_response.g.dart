// GENERATED CODE - DO NOT MODIFY BY HAND

part of token_response;

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<TokenResponse> _$tokenResponseSerializer =
    new _$TokenResponseSerializer();

class _$TokenResponseSerializer implements StructuredSerializer<TokenResponse> {
  @override
  final Iterable<Type> types = const [TokenResponse, _$TokenResponse];
  @override
  final String wireName = 'TokenResponse';

  @override
  Iterable<Object?> serialize(Serializers serializers, TokenResponse object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.accessToken;
    if (value != null) {
      result
        ..add('access_token')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.refreshToken;
    if (value != null) {
      result
        ..add('refresh_token')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.tokenType;
    if (value != null) {
      result
        ..add('token_type')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.expiresIn;
    if (value != null) {
      result
        ..add('expires_in')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.scope;
    if (value != null) {
      result
        ..add('scope')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  TokenResponse deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new TokenResponseBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'access_token':
          result.accessToken = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'refresh_token':
          result.refreshToken = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'token_type':
          result.tokenType = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'expires_in':
          result.expiresIn = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'scope':
          result.scope = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$TokenResponse extends TokenResponse {
  @override
  final String? accessToken;
  @override
  final String? refreshToken;
  @override
  final String? tokenType;
  @override
  final int? expiresIn;
  @override
  final String? scope;

  factory _$TokenResponse([void Function(TokenResponseBuilder)? updates]) =>
      (new TokenResponseBuilder()..update(updates)).build();

  _$TokenResponse._(
      {this.accessToken,
      this.refreshToken,
      this.tokenType,
      this.expiresIn,
      this.scope})
      : super._();

  @override
  TokenResponse rebuild(void Function(TokenResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TokenResponseBuilder toBuilder() => new TokenResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TokenResponse &&
        accessToken == other.accessToken &&
        refreshToken == other.refreshToken &&
        tokenType == other.tokenType &&
        expiresIn == other.expiresIn &&
        scope == other.scope;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc($jc($jc(0, accessToken.hashCode), refreshToken.hashCode),
                tokenType.hashCode),
            expiresIn.hashCode),
        scope.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('TokenResponse')
          ..add('accessToken', accessToken)
          ..add('refreshToken', refreshToken)
          ..add('tokenType', tokenType)
          ..add('expiresIn', expiresIn)
          ..add('scope', scope))
        .toString();
  }
}

class TokenResponseBuilder
    implements Builder<TokenResponse, TokenResponseBuilder> {
  _$TokenResponse? _$v;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  String? _tokenType;
  String? get tokenType => _$this._tokenType;
  set tokenType(String? tokenType) => _$this._tokenType = tokenType;

  int? _expiresIn;
  int? get expiresIn => _$this._expiresIn;
  set expiresIn(int? expiresIn) => _$this._expiresIn = expiresIn;

  String? _scope;
  String? get scope => _$this._scope;
  set scope(String? scope) => _$this._scope = scope;

  TokenResponseBuilder();

  TokenResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accessToken = $v.accessToken;
      _refreshToken = $v.refreshToken;
      _tokenType = $v.tokenType;
      _expiresIn = $v.expiresIn;
      _scope = $v.scope;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TokenResponse other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$TokenResponse;
  }

  @override
  void update(void Function(TokenResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$TokenResponse build() {
    final _$result = _$v ??
        new _$TokenResponse._(
            accessToken: accessToken,
            refreshToken: refreshToken,
            tokenType: tokenType,
            expiresIn: expiresIn,
            scope: scope);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
