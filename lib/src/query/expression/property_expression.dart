part of couchbase_lite;

class PropertyExpression extends Object with Expression {
  PropertyExpression(Map<String, dynamic> _passedInternalExpression) {
    this._internalExpressionStack.add(_passedInternalExpression);
  }

  PropertyExpression._clone(PropertyExpression expression) {
    this._internalExpressionStack.addAll(expression.internalExpressionStack);
  }

  @override
  PropertyExpression _clone() {
    return PropertyExpression._clone(this);
  }
}
