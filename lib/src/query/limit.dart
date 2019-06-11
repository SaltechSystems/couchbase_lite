part of couchbase_lite;

class Limit extends Query {
  Limit() {
    this._options = new Map<String, dynamic>();
    this.param = new Parameters();
  }

  Map<String, dynamic> toJson() => this.options;
}
