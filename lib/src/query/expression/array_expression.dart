part of couchbase_lite;

class ArrayExpression extends Object with Expression {
  ArrayExpression(Map<String, dynamic> _passedInternalExpression) {
    this._internalExpressionStack.add(_passedInternalExpression);
  }

  ArrayExpression._clone(ArrayExpression expression) {
    this._internalExpressionStack.addAll(expression.internalExpressionStack);
  }

  static const String _quantifiesTypeAny = 'arrayInAny';
  static const String _quantifiesTypeEvery = 'arrayInEvery';

  static ArrayExpressionIn any(VariableExpression variableExpression) {
    if (variableExpression == null) {
      throw Exception('variable cannot be null.');
    }
    return ArrayExpressionIn(_quantifiesTypeAny, variableExpression);
  }

  static ArrayExpressionIn every(VariableExpression variableExpression) {
    if (variableExpression == null) {
      throw Exception('variable cannot be null.');
    }
    return ArrayExpressionIn(_quantifiesTypeEvery, variableExpression);
  }

  static VariableExpression variable(String name) {
    if (name == null) {
      throw Exception('name cannnot be null.');
    }
    return VariableExpression({'arrayVariable': name});
  }

  @override
  ArrayExpression _clone() {
    return ArrayExpression._clone(this);
  }
}
