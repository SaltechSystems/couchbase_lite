part of couchbase_lite;

enum LogLevel { debug, verbose, info, warning, error, none }

class Log{
  static const MethodChannel _methodChannel =
  MethodChannel('com.saltechsystems.couchbase_lite/database');

   set level(LogLevel level) {
     _methodChannel.invokeMethod('setConsoleLogLevel', <String, dynamic>{'level': level.toString().split('.').last});
  }
}
