part of couchbase_lite;

class OrderBy extends Query {
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
}
