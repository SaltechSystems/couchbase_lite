part of couchbase_lite;

class Ordering {
  Ordering._internal(Expression _expression) {
    this._internalExpression = _expression;
  }

  factory Ordering.property(String _property) {
    return Ordering._internal(Expression.property(_property));
  }

  factory Ordering.expression(Expression _expression) {
    return Ordering._internal(_expression);
  }

  Expression _internalExpression;

  Ordering ascending() {
    Expression clone = _internalExpression._clone();
    clone._internalExpressionStack.add({"orderingSortOrder": "ascending"});
    return Ordering._internal(clone);
  }

  Ordering descending() {
    Expression clone = _internalExpression._clone();
    clone._internalExpressionStack.add({"orderingSortOrder": "descending"});
    return Ordering._internal(clone);
  }

  List<Map<String, dynamic>> toJson() {
    return _internalExpression.internalExpressionStack;
  }
}
