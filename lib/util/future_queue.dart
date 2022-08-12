import 'dart:collection';

import 'package:provenance_wallet/util/logs/logging.dart';

class FutureQueue {
  final _queue = Queue<WorkItem>();
  var _isWorking = false;

  void add(Future<void> Function() work) {
    _queue.add(
      WorkItem(
        work: work,
        trace: StackTrace.current,
      ),
    );
    if (!_isWorking) {
      _doWork();
    }
  }

  void dispose() {
    _queue.clear();
  }

  Future<void> _doWork() async {
    while (_queue.isNotEmpty) {
      _isWorking = true;
      final item = _queue.removeFirst();

      try {
        await item.work();
      } catch (e) {
        logError(
          'Work error enqueued by trace:\n${item.trace.toString()}',
          error: e,
        );
      }
    }

    _isWorking = false;
  }
}

class WorkItem {
  WorkItem({
    required this.work,
    required this.trace,
  });

  final Future<void> Function() work;
  final StackTrace trace;
}
