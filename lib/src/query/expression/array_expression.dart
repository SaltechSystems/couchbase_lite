part of couchbase_lite;

class ArrayExpression extends Object with Expression {
  ArrayExpression(Map<String, dynamic> _passedInternalExpression) {
    this._internalExpressionStack.add(_passedInternalExpression);
  }

  ArrayExpression._clone(ArrayExpression expression) {
    this._internalExpressionStack.addAll(expression.internalExpressionStack);
  }

//  //a variable to represent an element in the forms.primary_form.formData.assigned_to array
//  VariableExpression assignedToVariableExpression = ArrayExpression.variable("assigned_to");
//  //a variable to represent every element in the assigned_to array
//  Expression assignedToArrayExpression = Expression.property("forms.primary_form.formData.assigned_to");
//  Expression assignedToIdExpression = ArrayExpression.variable("assigned_to.id");
//  Expression assignedToTypeExpression = ArrayExpression.variable("assigned_to.type");

//  if (TextUtils.equals(Pref.getInstance().getUserLoginType(), Constant.LOGIN_TYPE_WEB)) {
//  mWhereExpression = ((createdByIdExpression.equalTo(Expression.string
//  (Pref.getInstance().getUserId())).and(createdFromExpression.equalTo(Expression.string("web"))
//      .or(createdFromExpression.equalTo(Expression.string("device")))))
//      .or(ArrayExpression.any(assignedToVariableExpression).in(assignedToArrayExpression)
//      .satisfies(assignedToIdExpression.equalTo(Expression.string
//  (Pref.getInstance().getUserId()))
//      .and(assignedToTypeExpression.equalTo(Expression.string
//  ("USERS"))))));

  static const String quantifiesTypeAny = "arrayInAny";

  static ArrayExpressionIn any(VariableExpression variableExpression) {
    if (variableExpression == null) {
      throw Exception("variable cannot be null.");
    }
    return ArrayExpressionIn(quantifiesTypeAny, variableExpression);
  }

  static VariableExpression variable(String name) {
    if (name == null) {
      throw Exception("name cannnot be null.");
    }
    return VariableExpression({"value": name});
  }

  @override
  ArrayExpression _clone() {
    return ArrayExpression._clone(this);
  }
}
