part of couchbase_lite;

class Select extends Query {
  From from(String databaseName, {String as}) {
    var resultQuery = From();
    resultQuery._options = this.options;
    if (as != null) {
      resultQuery._options["from"] = {"database": databaseName, "as": as};
    } else {
      resultQuery._options["from"] = {"database": databaseName};
    }
    return resultQuery;
  }
}
