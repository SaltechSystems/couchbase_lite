part of couchbase_lite;

class MetaExpression extends Object with Expression {
  MetaExpression(Map<String, dynamic> _passedInternalExpression) {
    _internalExpressionStack.add(_passedInternalExpression);
  }

  MetaExpression._clone(MetaExpression expression) {
    _internalExpressionStack.addAll(expression.internalExpressionStack);
  }

  @override
  MetaExpression _clone() {
    return MetaExpression._clone(this);
  }
}
