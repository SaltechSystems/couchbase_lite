part of couchbase_lite;

class ArrayFunctions with Expression {
  ArrayFunctions(Map<String, dynamic> _passedInternalExpression) {
    this._internalExpressionStack.add(_passedInternalExpression);
  }

  ArrayFunctions._clone(ArrayFunctions expression) {
    this._internalExpressionStack.addAll(expression.internalExpressionStack);
  }

  factory ArrayFunctions.length(Expression expression) {
    return ArrayFunctions({"length": expression.internalExpressionStack});
  }

  @override
  final List<Map<String, dynamic>> _internalExpressionStack = List();

  @override
  List<Map<String, dynamic>> get internalExpressionStack =>
      List.from(_internalExpressionStack);
  
  @override
  ArrayFunctions _clone() {
    return ArrayFunctions._clone(this);
  }

}
