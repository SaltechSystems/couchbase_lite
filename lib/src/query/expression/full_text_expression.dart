part of couchbase_lite;

class FullTextExpressionIndex {
  final String _name;
  FullTextExpressionIndex._(this._name);

  FullTextExpression match(String query) {
    return FullTextExpression._match(_name, query);
  }
}

class FullTextExpression extends Object with Expression {
  static FullTextExpressionIndex index(String name) {
    return FullTextExpressionIndex._(name);
  }

  factory FullTextExpression.rank(String indexName) {
    final expression = FullTextExpression._();
    expression._internalExpressionStack.add({'rank': indexName});
    return expression;
  }

  FullTextExpression._();

 FullTextExpression._match(String indexName, String query) {
    _internalExpressionStack.add({
      'fullTextMatch': [indexName, query],
    });
 }

  FullTextExpression._clone(FullTextExpression expression) {
    _internalExpressionStack.addAll(expression.internalExpressionStack);
  }

  @override
  FullTextExpression _clone() {
    return FullTextExpression._clone(this);
  }
}