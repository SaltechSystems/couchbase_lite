import 'parameters.dart';
import 'query.dart';

class Limit extends Query {
  Limit() {
    this.options = new Map<String, dynamic>();
    this.param = new Parameters();
  }

  Map<String, dynamic> toJson() => options;
}
