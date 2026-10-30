import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Rebuild a section only when the values it displays change.
class AudioStateBuilder extends StatefulWidget {
  const AudioStateBuilder({
    super.key,
    required this.listenable,
    required this.select,
    required this.builder,
  });
  final Listenable listenable;
  final List<Object?> Function() select;
  final WidgetBuilder builder;

  @override
  State<AudioStateBuilder> createState() => _AudioStateBuilderState();
}

class _AudioStateBuilderState extends State<AudioStateBuilder> {
  late List<Object?> _values;

  @override
  void initState() {
    super.initState();
    _values = widget.select();
    widget.listenable.addListener(_update);
  }

  void _update() {
    final next = widget.select();
    if (listEquals(_values, next)) return;
    setState(() => _values = next);
  }

  @override
  void didUpdateWidget(AudioStateBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenable != widget.listenable) {
      oldWidget.listenable.removeListener(_update);
      widget.listenable.addListener(_update);
    }
    _values = widget.select();
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}
