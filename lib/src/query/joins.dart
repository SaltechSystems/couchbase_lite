part of couchbase_lite;

class Joins extends Query {
  Joins() {
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

  Where where(Expression expression) {
    var resultQuery = new Where();
    resultQuery.options = this.options;
    resultQuery.options["where"] = expression;
    return resultQuery;
  }

  Map<String, dynamic> toJson() => options;
}
