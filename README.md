# Streamify

yet-another-state-management-library for flutter, but:

- Zero boilerplate.
- Simple and easy to use.
- No Jargon.
- No magic.

__Simply put__: this library would take a value and make into a stream, thus makes it consumable by `StreamBuilder`.

```dart
import 'package:streamify/streamify.dart';

/// creates a stream:
final counter = Streamify(0);

/// get the current value:
counter();

/// set a new value:
counter(1);

```

That's it!

## Flutter Widget Consumption

You would consume the stream in flutter using the `StreamBuilder` widget:

```dart
import 'package:flutter/material.dart';

final counter = Streamify(0);

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: counter.stream,
        builder: (context, snapshot) {
          return Text(counter().toString()); // accessing the current value
        },
    );
  }
}

/// now whenever you call counter(1) the text will change to 1

```

That's all you need to know to use this library. However, there's few more things that you can do:

1. The library gives you a utility widget that would watch multiple streams (instead of one) and update the UI accordingly: `MStreamBuilder`:
    ```dart
    import 'package:flutter/material.dart';

    final a = Streamify("a");
    final b = Streamify("b");

    class MyWidget extends StatelessWidget {
        @override
        Widget build(BuildContext context) {
            return MStreamBuilder(
                streams: [a.stream, b.stream],
                builder: (context, snapshot) {
                return Text("${a()} ${b()}");
                },
            );
        }
    }
    ```
2. You can change the value without emitting a new event (i.e without notifying the observers or updating the UI)
    ```dart
    final counter = Streamify(0);
    counter(1); // this will update the UI
    counter.silently(() => counter(10)); // silently set the value to 10
    ```

3. You can call `.observe` or `.unObserve` to add/remove custom observers to the stream.
4. You can call `.dispose` to dispose the stream and remove all observers, and prevent any further observations.


## But how to structure my state?

Given that this library is very simple, and the state is just a `final` variable, you can structure your state however you want, here's an example that creates a state class for a counter app:

```dart
import 'package:streamify/streamify.dart';

class _CounterAppState {
  // state
  final counter = Streamify(0);
  final isLoading = Streamify(false);

  // computed properties
  get counterByTwo => counter() * 2;

  // actions (methods)
  void reset() {
    counter(0);
  }

  void increment() {
    counter(counter() + 1);
  }

  void decrement() {
    counter(counter() - 1);
  }

  void fetchData() async {
    isLoading(true);
    await Future.delayed(Duration(seconds: 1));
    counter(counter() + 1);
    isLoading(false);
  }
}


// create an instance of the state
final counterAppState = _CounterAppState();
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License