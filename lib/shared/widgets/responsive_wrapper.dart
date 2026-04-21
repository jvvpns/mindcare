import 'package:flutter/material.dart';

/// A wrapper that ensures content is readable on wider screens by constraining 
/// its maximum width and centering it.
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final bool center;
  final EdgeInsets? padding;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 800,
    this.center = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget current = child;

    if (padding != null) {
      current = Padding(padding: padding!, child: current);
    }

    if (center) {
      current = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: current,
        ),
      );
    }

    return current;
  }
}
