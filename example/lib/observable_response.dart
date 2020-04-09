import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

// We will use observable responses to listen to changes in a query and
// propagate the changes back to the caller through the stream
class ObservableResponse<T> implements StreamController<T> {
  ObservableResponse(this._result, [this._onDispose]);

  final Subject<T> _result;
  final VoidCallback _onDispose;

  @override
  void add(data) => _result?.add(data);

  @override
  ControllerCallback get onCancel => throw UnsupportedError('ObservableResponses do not support cancel callbacks');

  @override
  ControllerCallback get onListen => throw UnsupportedError('ObservableResponses do not support listen callbacks');

  @override
  ControllerCallback get onPause => throw UnsupportedError('ObservableResponses do not support pause callbacks');

  @override
  ControllerCallback get onResume => throw UnsupportedError('ObservableResponses do not support resume callbacks');

  @override
  void addError(Object error, [StackTrace stackTrace]) => throw UnsupportedError('ObservableResponses do not support adding errors');

  @override
  Future addStream(Stream<T> source, {bool cancelOnError}) => throw UnsupportedError('ObservableResponses do not support adding streams');

  @override
  Future get done => _result?.done ?? true;

  @override
  bool get hasListener => _result?.hasListener ?? false;

  @override
  bool get isClosed => _result?.isClosed ?? true;

  @override
  bool get isPaused => _result?.isPaused ?? false;

  @override
  StreamSink<T> get sink => _result?.sink;

  @override
  Stream<T> get stream => _result?.stream;

  @override
  Future<dynamic> close() {
    if (_onDispose != null) {
      // Do operations here like closing streams and removing listeners
      _onDispose();
    }

    return _result?.close();
  }

  @override
  set onCancel(Function() onCancelHandler) => throw UnsupportedError('ObservableResponses do not support cancel callbacks');

  @override
  set onListen(void Function() onListenHandler) => throw UnsupportedError('ObservableResponses do not support listen callbacks');

  @override
  set onPause(void Function() onPauseHandler) => throw UnsupportedError('ObservableResponses do not support pause callbacks');

  @override
  set onResume(void Function() onResumeHandler) => throw UnsupportedError('ObservableResponses do not support resume callbacks');
}
