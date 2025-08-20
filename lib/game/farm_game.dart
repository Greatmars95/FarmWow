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
  
  CropType currentCropType = CropType.wheat; // Текущий выбранный тип культуры для посадки

  // Инвентарь семян (количество каждого типа)
  final Map<CropType, int> seedInventory = {
    CropType.wheat: 10,  // Начальное количество семян пшеницы
    CropType.carrot: 5,  // Начальное количество семян моркови
    CropType.cabbage: 5,
    CropType.onion: 5,
    CropType.potato: 5,
  };

  // Собранный урожай (количество каждого типа)
  final Map<CropType, int> harvestedCrops = {
    CropType.wheat: 0,
    CropType.carrot: 0,
    CropType.cabbage: 0,
    CropType.onion: 0,
    CropType.potato: 0,
  };

  // UI компоненты
  late TextComponent infoText;
  late TextComponent instructionsText;
  late TextComponent _seedSelectionText;
  late TextComponent _inventoryText;

  // Метод для выбора текущего типа культуры
  void selectCropType(CropType cropType) {
    currentCropType = cropType;
    print('Выбрано: ${cropType.name}');
    _updateUI(); // Обновить UI после выбора
  }

  // Метод для посадки семени (уменьшает количество в инвентаре)
  bool plantSeed(CropType cropType) {
    if (seedInventory[cropType]! > 0) {
      seedInventory[cropType] = seedInventory[cropType]! - 1;
      print('Посажено семя ${cropType.name}. Осталось: ${seedInventory[cropType]}');
      _updateUI(); // Обновить UI после посадки
      return true;
    }
    print('Нет семян ${cropType.name}');
    _updateUI(); // Обновить UI даже при неудачной посадке
    return false;
  }

  // Метод для сбора урожая (увеличивает количество в инвентаре)
  void collectCrop(CropType cropType) {
    harvestedCrops[cropType] = harvestedCrops[cropType]! + 1;
    print('Собран урожай ${cropType.name}. Всего: ${harvestedCrops[cropType]}');
    _updateUI(); // Обновить UI после сбора урожая
  }

  @override
  Future<void> onLoad() async {
    // ===== ФОН =====
    final backgroundSprite = await Sprite.load('tiles/area1.png');
    add(SpriteComponent(
      sprite: backgroundSprite,
      position: Vector2.zero(),
      size: Vector2(columns * tileSize, rows * tileSize), // Только для игровой сетки
    ));

    // ===== СЕТКА ИГРОВЫХ ТАЙЛОВ =====
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        // Создаем интерактивный тайл
        final farmTile = FarmTile(gridX: col, gridY: row);
        add(farmTile);

        // Рамка тайла - УДАЛЕНО
        // final border = RectangleComponent(
        //   position: Vector2(col * tileSize, row * tileSize),
        //   size: Vector2.all(tileSize),
        //   paint: Paint()
        //     ..color = Colors.black26
        //     ..style = PaintingStyle.stroke
        //     ..strokeWidth = 1.0,
        // );
        // add(border);
      }
    }

    // ===== UI ИНФОРМАЦИЯ =====
    // Инструкции
    instructionsText = TextComponent(
      text: '''🌱 ФЕРМА-СИМУЛЯТОР 🌱
1. Нажми на траву → грядка
2. Нажми на грядку → посади выбранное семя
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

    // Текст выбора семян
    _seedSelectionText = TextComponent(
      position: Vector2(size.x - 250, rows * tileSize + 10), // Справа вверху UI
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(_seedSelectionText);

    // Текст инвентаря
    _inventoryText = TextComponent(
      position: Vector2(size.x - 250, rows * tileSize + 50), // Справа внизу UI
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 10,
        ),
      ),
    );
    add(_inventoryText);

    // Кнопки выбора семян (пример)
    double buttonX = size.x - 250;
    double buttonY = rows * tileSize + 100;

    for (var cropType in CropType.values) {
      add(TextButtonComponent(
        text: cropType.name.toUpperCase(),
        position: Vector2(buttonX, buttonY),
        onPressed: () => selectCropType(cropType),
      ));
      buttonX += 70; // Сдвигаем кнопку
      if (buttonX > size.x - 50) { // Перенос на новую строку
        buttonX = size.x - 250;
        buttonY += 20;
      }
    }

    print('🌾 Ферма загружена! Тайлов: ${rows * columns}');
    print('📝 Используйте мышь или тап для взаимодействия с тайлами');

    _updateUI(); // Первичное обновление UI
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

    // Обновляем текст выбора семян
    _seedSelectionText.text = 'Выбрано: ${currentCropType.name.toUpperCase()} (Семян: ${seedInventory[currentCropType]}) ';

    // Обновляем текст инвентаря
    String inventoryStatus = 'Урожай:';
    harvestedCrops.forEach((type, count) {
      if (count > 0) {
        inventoryStatus += ' ${type.name}: $count';
      }
    });
    if (inventoryStatus == 'Урожай:') {
      inventoryStatus += ' пока нет';
    }
    _inventoryText.text = inventoryStatus;
  }
}

class TextButtonComponent extends TextComponent with TapCallbacks {
  final VoidCallback onPressed;

  TextButtonComponent({required String text, required Vector2 position, required this.onPressed})
      : super(
          text: text,
          position: position,
          textRenderer: TextPaint(
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