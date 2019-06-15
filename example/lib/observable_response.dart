//import 'package:rxdart/rxdart.dart';
//
//// We will use observable responses to listen to changes in a query and
//// propagate the changes back to the caller through the stream
//class ObservableResponse<T> {
//  ObservableResponse(this.result, this.onDispose);
//
//  final Observable<T> result;
//  final VoidFunc onDispose;
//
//  void dispose() {
//    if (onDispose != null) {
//      // Do operations here like closing streams and removing listeners
//      onDispose();
//    }
//  }
//}
