part of couchbase_lite;

class ArrayExpressionSatisfies extends Object with Expression {
  ArrayExpressionSatisfies(this.type, this.variable, this.inExpression) {
    _internalExpressionStack.add({type: inExpression.internalExpressionStack});
  }

  ArrayExpressionSatisfies._clone(ArrayExpressionSatisfies expression)
      : type = expression.type,
        this.variable = expression.variable,
        this.inExpression = expression.inExpression {
    _internalExpressionStack.add({type: inExpression.internalExpressionStack});
  }

  final String type;
  final VariableExpression variable;
  final Expression inExpression;

  Expression satisfies(Expression expression) {
    if (expression == null) {
      throw Exception('expression cannot be null.');
    }
    return QuantifiedExpression(type, variable, inExpression, expression);
  }

  @override
  ArrayExpressionSatisfies _clone() {
    return ArrayExpressionSatisfies._clone(this);
  }
}

class QuantifiedExpression extends Object with Expression {
  QuantifiedExpression(
    this.type,
    this.variable,
    this.inExpression,
    this.expression,
  ) {
    _internalExpressionStack.addAll(variable.internalExpressionStack);
    _internalExpressionStack.add({
      type: inExpression.internalExpressionStack,
      'satisfies': expression.internalExpressionStack,
    });
  }

  QuantifiedExpression._clone(QuantifiedExpression expression)
      : type = expression.type,
        this.expression = expression,
        this.variable = expression.variable,
        this.inExpression = expression.inExpression {
    _internalExpressionStack..addAll(expression.internalExpressionStack);
  }

  String type;
  VariableExpression variable;
  Expression inExpression;
  Expression expression;

  @override
  QuantifiedExpression _clone() {
    return QuantifiedExpression._clone(this);
  }
}
