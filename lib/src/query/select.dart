part of couchbase_lite;

class Select extends Query {
  Select() {
    super._options = new Map<String, dynamic>();
    super.param = new Parameters();
  }

  From from(String databaseName, {String as}) {
    var resultQuery = new From();
    resultQuery._options = this.options;
    if (as != null) {
      resultQuery._options["from"] = {"database": databaseName, "as": as};
    } else {
      resultQuery._options["from"] = {"database": databaseName};
    }
    return resultQuery;
  }
}
