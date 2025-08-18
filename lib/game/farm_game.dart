// lib/game/farm_game.dart
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../components/farm_tile.dart';

class FarmGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {
  // Константы для размеров игрового поля
  static const int rows = 8;
  static const int columns = 8;
  static const double tileSize = 64.0;
  
  // UI компоненты
  late TextComponent infoText;
  late TextComponent instructionsText;

  @override
  Future<void> onLoad() async {
    // ===== ФОН =====
    add(RectangleComponent(
      position: Vector2.zero(),
      size: Vector2(columns * tileSize, rows * tileSize + 120), // +120 для UI
      paint: Paint()..color = Colors.green.shade100,
    ));

    // ===== СЕТКА ИГРОВЫХ ТАЙЛОВ =====
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        // Создаем интерактивный тайл
        final farmTile = FarmTile(gridX: col, gridY: row);
        add(farmTile);

        // Рамка тайла
        final border = RectangleComponent(
          position: Vector2(col * tileSize, row * tileSize),
          size: Vector2.all(tileSize),
          paint: Paint()
            ..color = Colors.black26
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );
        add(border);
      }
    }

    // ===== UI ИНФОРМАЦИЯ =====
    // Инструкции
    instructionsText = TextComponent(
      text: '''🌱 ФЕРМА-СИМУЛЯТОР 🌱
1. Нажми на траву → грядка
2. Нажми на грядку → посади пшеницу  
3. Красный тайл = нужен полив
4. Желтый = урожай готов!''',
      position: Vector2(10, rows * tileSize + 10),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(instructionsText);

    // Игровая информация
    infoText = TextComponent(
      text: 'Кликай по тайлам чтобы начать фермерство! 🚜',
      position: Vector2(10, rows * tileSize + 90),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.green,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(infoText);
    
    print('🌾 Ферма загружена! Тайлов: ${rows * columns}');
    print('📝 Используйте мышь или тап для взаимодействия с тайлами');
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateUI();
  }

  void _updateUI() {
    // Подсчитываем статистику
    int grassTiles = 0;
    int tilledTiles = 0;
    int plantedTiles = 0;
    int grownTiles = 0;
    
    // Проходим по всем FarmTile компонентам
    for (final component in children) {
      if (component is FarmTile) {
        switch (component.stateString) {
          case 'grass':
            grassTiles++;
            break;
          case 'tilled':
            tilledTiles++;
            break;
          case 'planted':
          case 'watered':
            plantedTiles++;
            break;
          case 'grown':
            grownTiles++;
            break;
        }
      }
    }
    
    // Обновляем текст
    infoText.text = '''🌱 Статистика фермы:
🟢 Трава: $grassTiles  🟤 Грядки: $tilledTiles  🌾 Растет: $plantedTiles  ⭐ Готово: $grownTiles''';
  }
}

/*
🎮 КАК ИГРАТЬ:

1. СОЗДАНИЕ ГРЯДКИ:
   - Нажмите на зеленый тайл (трава)
   - Он станет коричневым (грядка готова)

2. ПОСАДКА:
   - Нажмите на коричневую грядку
   - Автоматически посадится пшеница
   - Тайл станет темно-коричневым

3. ПОЛИВ:
   - Через 5 секунд тайл станет красным = нужен полив
   - Нажмите на красный тайл чтобы полить
   - Он станет синим = полито (растет в 2 раза быстрее)

4. СБОР УРОЖАЯ:
   - Когда растение вырастет, тайл станет желтым
   - Нажмите чтобы собрать урожай
   - Тайл вернется к траве

⏱️ ВРЕМЯ РОСТА:
   - Пшеница: 10 секунд (без полива) / 5 секунд (с поливом)
   
🎯 ЦЕЛЬ:
   Просто экспериментируйте с фермой! Это базовая версия для изучения.
*/