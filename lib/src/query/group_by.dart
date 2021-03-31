part of couchbase_lite;

class GroupBy extends Query {
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

  Having having(Expression expression) {
    var resultQuery = Having();
    resultQuery._options = options;
    resultQuery._options['having'] = expression;
    return resultQuery;
  }
}
