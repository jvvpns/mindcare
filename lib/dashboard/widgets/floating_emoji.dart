import 'package:flutter/material.dart';

class FloatingEmoji extends StatefulWidget {
  final String emoji;
  final bool isSelected;
  const FloatingEmoji({super.key, required this.emoji, this.isSelected = false});

  @override
  State<FloatingEmoji> createState() => _FloatingEmojiState();
}

class _FloatingEmojiState extends State<FloatingEmoji> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yOffset;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _yOffset = Tween<double>(begin: 0, end: -4.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    
    _scale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double finalY = _yOffset.value;
        double finalScale = widget.isSelected ? (_scale.value + 0.05) : _scale.value;
        
        return Transform.translate(
          offset: Offset(0, finalY),
          child: Transform.scale(
            scale: finalScale,
            child: Text(
              widget.emoji,
              style: const TextStyle(fontSize: 26),
            ),
          ),
        );
      },
    );
  }
}
