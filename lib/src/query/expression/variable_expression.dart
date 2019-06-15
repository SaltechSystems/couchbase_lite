part of couchbase_lite;

class VariableExpression extends Object with Expression {
  VariableExpression(Map<String, dynamic> _passedInternalExpression) {
    this._internalExpressionStack.add(_passedInternalExpression);
  }

  VariableExpression._clone(VariableExpression expression) {
    this._internalExpressionStack.addAll(expression.internalExpressionStack);
  }

  @override
  VariableExpression _clone() {
    return VariableExpression._clone(this);
  }
}
