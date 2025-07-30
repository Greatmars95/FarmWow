import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class FarmGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {
  static const int rows = 10;
  static const int columns = 10;
  static const double tileSize = 64.0;

  @override
  Future<void> onLoad() async {
    // Генерируем зелёные тайлы с чёрной рамкой
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final position = Vector2(col * tileSize, row * tileSize);

        final tile = RectangleComponent(
          position: position,
          size: Vector2.all(tileSize),
          paint: Paint()
            ..color = Colors.green.shade300
            ..style = PaintingStyle.fill,
        );

        final border = RectangleComponent(
          position: position,
          size: Vector2.all(tileSize),
          paint: Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );

        add(tile);
        add(border);
      }
    }

    // Красный тестовый квадрат
    add(RectangleComponent(
      position: Vector2.zero(),
      size: Vector2.all(100),
      paint: Paint()..color = Colors.red,
    ));
  }
}