import 'dart:async';
import 'package:flutter/widgets.dart';

/// __Multi-stream builder__
///
/// It's similar to the StreamBuilder widget, but it allows you to listen to multiple streams and build a widget based on the latest values of those streams.
/// Usage:
/// ```dart
/// MultiStreamBuilder(
/// streams: [ stream1, stream2, stream3 ],
/// builder: (context, data) {
///   return Text(data.toString());
/// },
class MStreamBuilder<T> extends StatefulWidget {
  final List<Stream<T>> streams;
  final Widget Function(BuildContext context, List<T?> data) builder;

  const MStreamBuilder({
    required this.streams,
    required this.builder,
    super.key,
  });

  @override
  createState() => _MStreamBuilderState<T>();
}

class _MStreamBuilderState<T> extends State<MStreamBuilder<T>> {
  late List<T?> _data;
  late List<StreamSubscription<T>> _subscriptions;

  @override
  void initState() {
    super.initState();
    _data = List<T?>.filled(widget.streams.length, null);
    _subscriptions = widget.streams.asMap().entries.map((entry) {
      final index = entry.key;
      final stream = entry.value;
      return stream.listen((value) {
        setState(() {
          _data[index] = value;
        });
      });
    }).toList();
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _data);
  }
}
