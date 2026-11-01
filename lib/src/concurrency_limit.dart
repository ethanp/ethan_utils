import 'dart:async';
import 'dart:collection';

/// Runs at most [maxConcurrent] tasks at once; later tasks wait in FIFO order.
class ConcurrencyLimit(final int maxConcurrent) {
  int _running = 0;
  final Queue<Completer<void>> _waiting = Queue();

  Future<T> run<T>(Future<T> Function() task) async {
    await _claimSlot();
    try {
      return await task();
    } finally {
      _releaseSlot();
    }
  }

  Future<void> _claimSlot() async {
    if (_running < maxConcurrent) {
      _running++;
      return;
    }
    final turn = Completer<void>();
    _waiting.add(turn);
    await turn.future;
  }

  /// Hands the slot straight to the next waiter, so [_running] stays claimed.
  void _releaseSlot() {
    if (_waiting.isEmpty) {
      _running--;
      return;
    }
    _waiting.removeFirst().complete();
  }
}
