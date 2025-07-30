import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

// Основной класс игры с поддержкой спрайтов (изображений)
class FarmGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {
  // Константы для размеров игрового поля
  static const int rows = 10;
  static const int columns = 10;
  static const double tileSize = 64.0;

  @override
  Future<void> onLoad() async {
    // ===== ФОН =====
    // Попробуем загрузить изображение фона, если не получится - используем цвет
    try {
      final backgroundSprite = await loadSprite('background.png');
      add(SpriteComponent(
        sprite: backgroundSprite,
        position: Vector2.zero(),
        size: Vector2(columns * tileSize, rows * tileSize),
      ));
    } catch (e) {
      // Если картинки нет - используем цветной фон
      print('Фоновое изображение не найдено, используем цвет: $e');
      add(RectangleComponent(
        position: Vector2.zero(),
        size: Vector2(columns * tileSize, rows * tileSize),
        paint: Paint()..color = Colors.brown.shade200,
      ));
    }

    // ===== СЕТКА ТАЙЛОВ =====
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final position = Vector2(col * tileSize, row * tileSize);

        // Попробуем загрузить спрайт тайла
        try {
          final tileSprite = await loadSprite('tiles/area1.png');
          
          // Создаем тайл с изображением
          add(SpriteComponent(
            sprite: tileSprite,
            position: position,
            size: Vector2.all(tileSize),
          ));
          
        } catch (e) {
          // Если картинки нет - используем цветной прямоугольник
          print('Изображение тайла не найдено, используем цвет: $e');
          
          final tile = RectangleComponent(
            position: position,
            size: Vector2.all(tileSize),
            paint: Paint()
              ..color = Colors.green.shade300
              ..style = PaintingStyle.fill,
          );
          add(tile);
        }

        // Рамка тайла (всегда рисуем поверх)
        final border = RectangleComponent(
          position: position,
          size: Vector2.all(tileSize),
          paint: Paint()
            ..color = Colors.black26  // более прозрачная рамка
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );
        add(border);
      }
    }

    // ===== ПЕРСОНАЖ =====
    // Попробуем загрузить спрайт персонажа
    try {
      final playerSprite = await loadSprite('characters/char1.png');
      
      add(SpriteComponent(
        sprite: playerSprite,
        position: Vector2(tileSize * 2.5, tileSize * 2.5), // центр 3-го тайла
        size: Vector2(tileSize * 0.8, tileSize * 0.8),
        anchor: Anchor.center,
      ));
      
    } catch (e) {
      // Если картинки нет - используем цветной квадрат
      print('Изображение персонажа не найдено, используем цвет: $e');
      
      final player = RectangleComponent(
        position: Vector2(tileSize * 2.5, tileSize * 2.5),
        size: Vector2(tileSize * 0.8, tileSize * 0.8),
        paint: Paint()..color = Colors.blue,
        anchor: Anchor.center,
      );
      add(player);
    }
    
    print('Игра загружена! Тайлов: ${rows * columns}');
  }
}

/*
ФАЙЛЫ ИЗОБРАЖЕНИЙ:

Рекомендуемые размеры:
- Тайлы: 64x64 пикселей
- Персонаж: 48x48 пикселей  
- Фон: 640x640 пикселей

Поддерживаемые форматы: PNG, JPG, GIF

СТРУКТУРА ФАЙЛОВ:
assets/images/
├── background.png          ← фон всей карты
├── tiles/
│   ├── grass.png          ← трава
│   ├── dirt.png           ← земля
│   └── field.png          ← вспаханное поле
└── characters/
    ├── player.png         ← персонаж стоит
    └── player_walk.png    ← персонаж идет
*/