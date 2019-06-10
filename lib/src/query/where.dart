part of couchbase_lite;

class Where extends Query {
  Where() {
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

  OrderBy orderBy(List<Ordering> orderingList) {
    var resultQuery = new OrderBy();
    resultQuery.options = this.options;
    resultQuery.options["orderBy"] = orderingList;
    return resultQuery;
  }

  GroupBy groupBy(List<Expression> expressionList) {
    var resultQuery = new GroupBy();
    resultQuery.options = this.options;
    resultQuery.options["groupBy"] = expressionList;
    return resultQuery;
  }

  Map<String, dynamic> toJson() => options;
}
