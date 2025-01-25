import 'dart:async';
import 'package:test/test.dart';
import 'package:streamify/streamify.dart';

void main() {
  group('Streamify Library Tests', () {
    group('Basic Usage', () {
      test('Initial value is set correctly', () {
        final counter = Streamify(0);
        expect(counter(), equals(0));
      });

      test('Value can be updated and retrieved', () {
        final counter = Streamify(0);
        counter(10);
        expect(counter(), equals(10));
      });

      test('Observers are notified on value update', () async {
        final counter = Streamify(0);
        int? notifiedValue;

        counter.observe((value) => notifiedValue = value);

        counter(42);
        await Future.delayed(Duration.zero); // Wait for async stream processing

        expect(notifiedValue, equals(42));
      });

      test('Multiple observers are notified', () async {
        final counter = Streamify(0);
        final values = <int>[];

        counter.observe((value) => values.add(value));
        counter.observe((value) => values.add(value * 2));

        counter(5);
        await Future.delayed(Duration.zero);

        expect(values, equals([5, 10]));
      });

      test('Observers can be removed', () async {
        final counter = Streamify(0);
        int? notifiedValue;

        final observer = (int value) => notifiedValue = value;
        counter.observe(observer);
        counter.unObserve(observer);

        counter(20);
        await Future.delayed(Duration.zero);

        expect(notifiedValue, isNull);
      });

      test('Observers are not notified after dispose', () async {
        final counter = Streamify(0);
        bool notified = false;

        counter.observe((value) => notified = true);
        counter.dispose();

        counter(5);
        await Future.delayed(Duration.zero);

        expect(notified, isFalse);
      });
    });

    group('Moderate Usage', () {
      test('Silent updates do not notify observers', () async {
        final counter = Streamify(0);
        int? notifiedValue;

        counter.observe((value) => notifiedValue = value);

        counter.silently(() => counter(100));
        await Future.delayed(Duration.zero);

        expect(notifiedValue, isNull);
        expect(counter(), equals(100));
      });

      test('Dispose clears observers and prevents further updates', () {
        final counter = Streamify(0);
        counter.observe((value) {});

        counter.dispose();

        expect(() => counter(1), returnsNormally);
        expect(() => counter.notifyObservers(1), returnsNormally);
      });

      test('Stream updates are received in correct order', () async {
        final counter = Streamify(0);
        final values = <int>[];

        counter.observe((value) => values.add(value));

        counter(1);
        counter(2);
        counter(3);

        await Future.delayed(Duration.zero);

        expect(values, equals([1, 2, 3]));
      });

      test('Can not observe the same callback multiple times', () async {
        final counter = Streamify(0);
        int callCount = 0;

        final observer = (int value) => callCount++;
        counter.observe(observer);
        counter.observe(observer);

        counter(10);
        await Future.delayed(Duration.zero);

        expect(callCount, equals(1));
      });
    });

    group('State Structuring', () {
      test('State can be encapsulated in a class', () async {
        final state = _CounterAppState();

        state.increment();
        expect(state.counter(), equals(1));

        state.increment();
        expect(state.counter(), equals(2));

        state.reset();
        expect(state.counter(), equals(0));
      });

      test('Computed properties work as expected', () {
        final state = _CounterAppState();

        state.counter(5);
        expect(state.counterByTwo, equals(10));

        state.counter(7);
        expect(state.counterByTwo, equals(14));
      });

      test('Actions trigger updates correctly', () async {
        final state = _CounterAppState();
        int? lastObservedValue;

        state.counter.observe((value) => lastObservedValue = value);

        state.increment();
        await Future.delayed(Duration.zero);

        expect(lastObservedValue, equals(1));

        state.decrement();
        await Future.delayed(Duration.zero);

        expect(lastObservedValue, equals(0));
      });
    });

    group('Edge Cases', () {
      test('Setting the same value DOES trigger notifications', () async {
        final counter = Streamify(0);
        int notifyCount = 0;

        counter.observe((value) => notifyCount++);

        counter(0);
        await Future.delayed(Duration.zero);

        expect(notifyCount, equals(1));
      });

      test('Adding events after dispose does not throw', () {
        final counter = Streamify(0);

        counter.dispose();

        expect(() => counter(1), returnsNormally);
      });

      test('Silent block nesting works as expected', () {
        final counter = Streamify(0);
        int notifyCount = 0;

        counter.observe((value) => notifyCount++);

        counter.silently(() {
          counter.silently(() {
            counter(100);
          });
        });

        expect(counter(), equals(100));
        expect(notifyCount, equals(0));
      });

      test('Streamify works correctly with multiple data types', () async {
        final stringState = Streamify("hello");
        final boolState = Streamify(false);

        stringState.observe((value) {
          expect(value, isA<String>());
        });

        boolState.observe((value) {
          expect(value, isA<bool>());
        });

        stringState("world");
        boolState(true);

        await Future.delayed(Duration.zero);

        expect(stringState(), equals("world"));
        expect(boolState(), isTrue);
      });

      test('Notifying observers after stream is closed throws no errors', () {
        final counter = Streamify(0);
        counter.dispose();

        expect(() => counter.notifyObservers(10), returnsNormally);
      });
    });
  });
}

/// Example app state used for testing.
class _CounterAppState {
  final counter = Streamify(0);
  final isLoading = Streamify(false);

  int get counterByTwo => counter() * 2;

  void reset() {
    counter(0);
  }

  void increment() {
    counter(counter() + 1);
  }

  void decrement() {
    counter(counter() - 1);
  }
}
