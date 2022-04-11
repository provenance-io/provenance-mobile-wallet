import 'dart:async';

class TimedCounter {
  TimedCounter({
    required Function() onSuccess,
    int requiredCount = 10,
    Duration duration = const Duration(
      seconds: 5,
    ),
  })  : _onSuccess = onSuccess,
        _requiredCount = requiredCount,
        _duration = duration;
  final int _requiredCount;
  final Duration _duration;
  final Function() _onSuccess;

  Timer? _timer;
  var _count = 0;

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _count = 0;
  }

  void increment() {
    if (_timer == null) {
      _startTimer();
    }

    _count++;

    if (_count == _requiredCount) {
      _onSuccess();
    }
  }

  void _startTimer() {
    _timer = Timer(_duration, () {
      _count = 0;
      _timer = null;
    });
  }
}
