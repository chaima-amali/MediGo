import 'dart:async';

/// A simple singleton broadcaster used to notify listeners when the
/// database has been changed (insert/update/delete). Repositories
/// performing write operations should call `notify()` so consumers
/// (like statistics cubits) can refresh automatically.
class DatabaseChangeNotifier {
  DatabaseChangeNotifier._internal();

  static final DatabaseChangeNotifier _instance =
      DatabaseChangeNotifier._internal();

  static DatabaseChangeNotifier get instance => _instance;

  final StreamController<void> _ctrl = StreamController<void>.broadcast();

  Stream<void> get stream => _ctrl.stream;

  void notify() {
    try {
      _ctrl.add(null);
    } catch (_) {}
  }

  void dispose() {
    _ctrl.close();
  }
}
