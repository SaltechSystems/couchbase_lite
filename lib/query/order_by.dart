import 'expression/expression.dart';
import 'limit.dart';
import 'parameters.dart';
import 'query.dart';

class OrderBy extends Query {
  OrderBy() {
    this.options = new Map<String, dynamic>();
    this.param = new Parameters();
  }

  Limit limit(Expression expression, {Expression offset}) {
    var resultQuery = new Limit();
    resultQuery.options = this.options;
    resultQuery.options["limit"] = expression;
    if (offset != null) {
      resultQuery.options["offset"] = offset;
    }
    return resultQuery;
  }

  Map<String, dynamic> toJson() => options;
}
