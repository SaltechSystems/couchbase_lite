part of couchbase_lite;

class MutableDocument extends Document {
  String id;

  MutableDocument([Map<dynamic, dynamic> data, String id]) : super(data, id) {
    this.id = id;
  }

  setValue(String key, Object value) {
    if (value != null) {
      super._data[key] = value;
    }
  }

  setArray(String key, List<Object> value) {
    setValue(key, value);
  }

  setBoolean(String key, bool value) {
    setValue(key, value);
  }

  setDouble(String key, double value) {
    setValue(key, value);
  }

  setInt(String key, int value) {
    setValue(key, value);
  }

  setString(String key, String value) {
    setValue(key, value);
  }

  remove(String key) {
    super._data.remove(key);
  }
}
