part of couchbase_lite;

class ArrayExpressionIn extends Object with Expression {
  ArrayExpressionIn(this.type, this.variable) {
    this._internalExpressionStack.addAll(variable.internalExpressionStack);
  }

  ArrayExpressionIn._clone(ArrayExpressionIn expression)
      : type = expression.type,
        this.variable = expression.variable {
    this._internalExpressionStack.addAll(variable.internalExpressionStack);
  }

  final String type;
  final VariableExpression variable;

  ArrayExpressionSatisfies inA(Expression inExpression) {
    return ArrayExpressionSatisfies(type, variable, inExpression);
  }

  @override
  ArrayExpressionIn _clone() {
    return ArrayExpressionIn._clone(this);
  }
}
