part of couchbase_lite;

class QueryBuilder {
  static Select select(List<SelectResultProtocol> _selectResult) {
    var query = Select();
    query._options["selectDistinct"] = false;
    query._options["selectResult"] = _selectResult;
    return query;
  }

  static Select selectDistinct(List<SelectResultProtocol> _selectResult) {
    var query = Select();
    query._options["selectDistinct"] = true;
    query._options["selectResult"] = _selectResult;
    return query;
  }
}
