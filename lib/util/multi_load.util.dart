


import 'dart:async';

class MultiLoadUtil {
  int _noOfLoad = 0;
  Completer _completer = Completer();
  startLoading() {
    _noOfLoad++;
    _makeNewCompleterSafe();
  }
  _makeNewCompleterSafe() {
    if (_completer.isCompleted) {
      _completer = Completer();
    }
  }
  stopLoading() {
    _noOfLoad--;
    if (_noOfLoad <=0) {
      _noOfLoad = 0;
      _makeCompleterSafeStop();
    }
  }
  Future<void> makeSafe() async {
    await _completer.future;
  }
  _makeCompleterSafeStop() {
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }
}