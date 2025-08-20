import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // Для TextPaint

class TextButtonComponent extends TextComponent with TapCallbacks {
  final VoidCallback onPressed;

  TextButtonComponent({required String text, required Vector2 position, required this.onPressed,
    TextPaint? textRenderer // Теперь это опциональный параметр
  })
      : super(
          text: text,
          position: position,
          textRenderer: textRenderer ?? TextPaint(
            style: const TextStyle(
              color: Colors.deepPurple,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

  @override
  bool onTapDown(TapDownEvent event) {
    onPressed.call();
    return true;
  }
}
