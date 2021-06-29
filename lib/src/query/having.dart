part of couchbase_lite;

class Having extends Query {
  Limit limit(Expression expression, {Expression? offset}) {
    var resultQuery = Limit();
    resultQuery._options = options;
    if (offset != null) {
      resultQuery._options['limit'] = [expression, offset];
    } else {
      resultQuery._options['limit'] = [expression];
    }
    return resultQuery;
  }

  OrderBy orderBy(List<Ordering> orderingList) {
    var resultQuery = OrderBy();
    resultQuery._options = options;
    resultQuery._options['orderBy'] = orderingList;
    return resultQuery;
  }
}
