part of couchbase_lite;

class QueryBuilder {
  static Select select(List<SelectResultProtocol> _selectResult) {
    var query = Select();
    query.options["selectDistinct"] = false;
    query.options["selectResult"] = _selectResult;
    return query;
  }

  static Select selectDistinct(List<SelectResultProtocol> _selectResult) {
    var query = Select();
    query.options["selectDistinct"] = true;
    query.options["selectResult"] = _selectResult;
    return query;
  }
}
