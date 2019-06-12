part of couchbase_lite;

class Where extends Query {
  Limit limit(Expression expression, {Expression offset}) {
    var resultQuery = new Limit();
    resultQuery._options = this.options;
    if (offset != null) {
      resultQuery._options["limit"] = [expression, offset];
    } else {
      resultQuery._options["limit"] = [expression];
    }
    return resultQuery;
  }

  OrderBy orderBy(List<Ordering> orderingList) {
    var resultQuery = new OrderBy();
    resultQuery._options = this.options;
    resultQuery._options["orderBy"] = orderingList;
    return resultQuery;
  }

  GroupBy groupBy(List<Expression> expressionList) {
    var resultQuery = new GroupBy();
    resultQuery._options = this.options;
    resultQuery._options["groupBy"] = expressionList;
    return resultQuery;
  }
}
