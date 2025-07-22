import 'package:flutter/widgets.dart';

class MeasureSize extends StatefulWidget {
  final Widget child;
  final Function(Size) onChange;

  const MeasureSize({super.key, required this.child, required this.onChange});

  @override
  _MeasureSizeState createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  Size oldSize = Size.zero;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = context.size ?? Size.zero;
      if (size != oldSize) {
        oldSize = size;
        widget.onChange(size);
      }
    });
    return widget.child;
  }
}
