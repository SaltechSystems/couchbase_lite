part of couchbase_lite;

class Functions extends Object with Expression {
  Functions(Map<String, dynamic> _passedInternalExpression) {
    this._internalExpressionStack.add(_passedInternalExpression);
  }

  Functions._clone(Functions expression) {
    this._internalExpressionStack.addAll(expression.internalExpressionStack);
  }

  factory Functions.abs(Expression expression) {
    return Functions({"abs": expression.internalExpressionStack});
  }

  factory Functions.acos(Expression expression) {
    return Functions({"acos": expression.internalExpressionStack});
  }

  factory Functions.asin(Expression expression) {
    return Functions({"asin": expression.internalExpressionStack});
  }

  factory Functions.atan(Expression expression) {
    return Functions({"atan": expression.internalExpressionStack});
  }

  factory Functions.atan2(Expression x, Expression y) {
    return Functions(
        {"atan2": x.internalExpressionStack, "y": y.internalExpressionStack});
  }

  factory Functions.avg(Expression expression) {
    return Functions({"avg": expression.internalExpressionStack});
  }

  factory Functions.ceil(Expression expression) {
    return Functions({"ceil": expression.internalExpressionStack});
  }

  factory Functions.contains(Expression expression, Expression substring) {
    return Functions({
      "contains": expression.internalExpressionStack,
      "y": substring.internalExpressionStack
    });
  }

  factory Functions.cos(Expression expression) {
    return Functions({"cos": expression.internalExpressionStack});
  }

  factory Functions.count(Expression expression) {
    return Functions({"count": expression.internalExpressionStack});
  }

  factory Functions.degrees(Expression expression) {
    return Functions({"degrees": expression.internalExpressionStack});
  }

  factory Functions.e() {
    return Functions({"e": null});
  }

  factory Functions.exp(Expression expression) {
    return Functions({"exp": expression.internalExpressionStack});
  }

  factory Functions.floor(Expression expression) {
    return Functions({"floor": expression.internalExpressionStack});
  }

  factory Functions.length(Expression expression) {
    return Functions({"length": expression.internalExpressionStack});
  }

  factory Functions.ln(Expression expression) {
    return Functions({"ln": expression.internalExpressionStack});
  }

  factory Functions.log(Expression expression) {
    return Functions({"log": expression.internalExpressionStack});
  }

  factory Functions.lower(Expression expression) {
    return Functions({"lower": expression.internalExpressionStack});
  }

  factory Functions.ltrim(Expression expression) {
    return Functions({"ltrim": expression.internalExpressionStack});
  }

  factory Functions.max(Expression expression) {
    return Functions({"max": expression.internalExpressionStack});
  }

  factory Functions.min(Expression expression) {
    return Functions({"min": expression.internalExpressionStack});
  }

  factory Functions.pi() {
    return Functions({"pi": null});
  }

  factory Functions.power(Expression base, Expression exponent) {
    return Functions({
      "power": base.internalExpressionStack,
      "exponent": exponent.internalExpressionStack
    });
  }

  factory Functions.radians(Expression expression) {
    return Functions({"radians": expression.internalExpressionStack});
  }

  factory Functions.round(Expression expression, {Expression digits}) {
    if (digits != null) {
      return Functions({
        "round": expression.internalExpressionStack,
        "digits": digits.internalExpressionStack
      });
    } else {
      return Functions({"round": expression.internalExpressionStack});
    }
  }

  factory Functions.rtrim(Expression expression) {
    return Functions({"rtrim": expression.internalExpressionStack});
  }

  factory Functions.sign(Expression expression) {
    return Functions({"sign": expression.internalExpressionStack});
  }

  factory Functions.sin(Expression expression) {
    return Functions({"sin": expression.internalExpressionStack});
  }

  factory Functions.sqrt(Expression expression) {
    return Functions({"sqrt": expression.internalExpressionStack});
  }

  factory Functions.sum(Expression expression) {
    return Functions({"sum": expression.internalExpressionStack});
  }

  factory Functions.tan(Expression expression) {
    return Functions({"tan": expression.internalExpressionStack});
  }

  factory Functions.trim(Expression expression) {
    return Functions({"trim": expression.internalExpressionStack});
  }

  factory Functions.trunc(Expression expression, {Expression digits}) {
    if (digits != null) {
      return Functions({
        "trunc": expression.internalExpressionStack,
        "digits": digits.internalExpressionStack
      });
    } else {
      return Functions({"trunc": expression.internalExpressionStack});
    }
  }

  factory Functions.upper(Expression expression) {
    return Functions({"upper": expression.internalExpressionStack});
  }

  @override
  Functions _clone() {
    return Functions._clone(this);
  }
}
