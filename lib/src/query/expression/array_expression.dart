part of couchbase_lite;

import '../../../couchbase_lite.dart';
import 'array_expression_in.dart';

class ArrayExpression extends Object with Expression{

  e QuantifiesType {
  ANY,
  ANY_AND_EVERY,
  EVERY
  }


//  if (TextUtils.equals(Pref.getInstance().getUserLoginType(), Constant.LOGIN_TYPE_WEB)) {
//  mWhereExpression = ((createdByIdExpression.equalTo(Expression.string
//  (Pref.getInstance().getUserId())).and(createdFromExpression.equalTo(Expression.string("web"))
//      .or(createdFromExpression.equalTo(Expression.string("device")))))
//      .or(ArrayExpression.any(assignedToVariableExpression).in(assignedToArrayExpression)
//      .satisfies(assignedToIdExpression.equalTo(Expression.string
//  (Pref.getInstance().getUserId()))
//      .and(assignedToTypeExpression.equalTo(Expression.string
//  ("USERS"))))));

  ArrayExpression(Map<String, dynamic> _passedInternalExpression) {
    this._internalExpressionStack.add(_passedInternalExpression);
  }

  ArrayExpression._clone(PropertyExpression expression) {
    this._internalExpressionStack.addAll(expression.internalExpressionStack);
  }

  factory ArrayExpression.variable(Object value) {
    return VariableExpression({"value": value});
  }

  @override
  ArrayExpression _clone() {
    return ArrayExpression._clone(this);
  }

  factory ArrayExpression.any(VariableExpression variableExpression){
    return ArrayExpressionIn();
  }


}