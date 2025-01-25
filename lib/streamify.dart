import 'dart:async';

typedef Observer<S> = void Function(S event);

/// Base class for stream pattern
///
/// You may extend this class to create other observable classes.
class StreamifyBase<S> {
  StreamifyBase() {
    stream.listen((event) {
      final List<Object> errs = [];
      for (var observer in observers) {
        try {
          observer(event);
        } catch (e) {
          errs.add(e);
        }
      }
      if (errs.isNotEmpty) {
        throw errs.first;
      }
    });
  }

  final StreamController<S> _controller = StreamController<S>.broadcast();
  double _silent = 0;

  /// List of observers
  final List<Observer<S>> observers = [];

  /// Stream of events (consumable by StreamBuilder)
  Stream<S> get stream => _controller.stream;

  /// Notify observers (emits stream event)
  void notifyObservers(S event) {
    if (_silent != 0 || _controller.isClosed) return;
    _controller.add(event);
  }

  /// Add an observer
  int observe(Observer<S> callback) {
    int existing = observers.indexWhere((o) => o == callback);
    if (existing > -1) {
      return existing;
    }
    observers.add(callback);
    return observers.length - 1;
  }

  /// Remove an observer
  void unObserve(Observer<S> callback) {
    observers.removeWhere((existing) => existing == callback);
  }

  /// Remove all observers
  void dispose() {
    _silent = double.maxFinite;
    observers.clear();
    if (!_controller.isClosed) {
      _controller.close();
    }
  }

  /// Silently execute a function,
  /// whatever gets executed inside the context of this function
  /// would not notify observers
  /// i.e. no stream events would be emitted
  void silently(void Function() fn) {
    _silent++;
    try {
      fn();
    } finally {
      _silent--;
    }
  }
}

/// Creates a state stream
///
/// the value can be accessed by calling it "()"
/// the value can be changed by calling it with a new value "(newValue)"
class Streamify<T> extends StreamifyBase<T> {
  T _value;

  Streamify(this._value);

  T call([T? newValue]) {
    if (newValue != null) {
      _value = newValue;
      notifyObservers(_value);
    }
    return _value;
  }
}
