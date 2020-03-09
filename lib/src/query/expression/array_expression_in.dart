
import 'package:couchbase_lite/couchbase_lite.dart';

class ArrayExpressionIn extends ArrayExpression{

  ArrayExpressionIn() {
    this._internalExpressionStack.add(_passedInternalExpression);
  }

  ArrayExpressionIn._clone(ArrayExpressionIn expression) {
    this._internalExpressionStack.addAll(expression.internalExpressionStack);
  }

  ArrayExpressionSatisfies in(Expression expression){
    return ArrayExpressionSatisfies();
  }

  @override
  ArrayExpressionIn _clone() {
    return ArrayExpressionIn._clone(this);
  }

}