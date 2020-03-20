part of couchbase_lite;

class From extends Query {
  Where where(Expression expression) {
    var resultQuery = Where();
    resultQuery._options = this.options;
    resultQuery._options["where"] = expression;
    return resultQuery;
  }

  GroupBy groupBy(List<Expression> expressionList) {
    var resultQuery = GroupBy();
    resultQuery._options = this.options;
    resultQuery._options["groupBy"] = expressionList;
    return resultQuery;
  }

  Joins join(Join expression) {
    var resultQuery = Joins();
    resultQuery._options = this.options;
    resultQuery._options["joins"] = expression;
    return resultQuery;
  }

  Limit limit(Expression expression, {Expression offset}) {
    var resultQuery = Limit();
    resultQuery._options = this.options;
    if (offset != null) {
      resultQuery._options["limit"] = [expression, offset];
    } else {
      resultQuery._options["limit"] = [expression];
    }
    return resultQuery;
  }

  OrderBy orderBy(List<Ordering> orderingList) {
    var resultQuery = OrderBy();
    resultQuery._options = this.options;
    resultQuery._options["orderBy"] = orderingList;
    return resultQuery;
  }
}
