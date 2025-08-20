import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../game/farm_game.dart';
import '../components/farm_tile.dart'; // Для CropType
import '../components/text_button_component.dart'; // Добавили импорт TextButtonComponent

class InventoryOverlay extends PositionComponent with TapCallbacks, HasGameRef<FarmGame> {
  final FarmGame game;

  InventoryOverlay({required this.game, required Vector2 position, required Vector2 size})
      : super(position: position, size: size) {
    // Убедимся, что overlay находится поверх всего
    priority = 100;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Фон инвентаря
    add(RectangleComponent(
      position: Vector2.zero(),
      size: size,
      paint: Paint()..color = Colors.black.withOpacity(0.7),
    ));

    // Заголовок
    add(TextComponent(
      text: 'ИНВЕНТАРЬ',
      position: Vector2(size.x / 2, 50), // Центрируем по ширине
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));

    // Кнопка закрытия
    add(TextButtonComponent(
      text: 'X ЗАКРЫТЬ',
      position: Vector2(size.x - 100, 20),
      onPressed: game.closeInventory,
    ));

    // Размещение кнопок выбора семян и информации об инвентаре
    _createInventoryUI();
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Обновляем UI инвентаря всегда, когда компонент активен в дереве (isVisible не нужен)
    _updateInventoryUI();
  }

  void _createInventoryUI() {
    // Удаляем старые элементы UI перед созданием новых (при перерисовке)
    removeAll(children.whereType<TextComponent>().where((c) => c.text != 'ИНВЕНТАРЬ'));
    removeAll(children.whereType<TextButtonComponent>());

    double yOffset = 100; // Начальная позиция для элементов UI

    // Секция выбора семян
    add(TextComponent(
      text: 'Выберите семя для посадки:',
      position: Vector2(50, yOffset),
      textRenderer: TextPaint(style: const TextStyle(color: Colors.white, fontSize: 18)),
    ));
    yOffset += 30;

    double buttonX = 50;
    for (var cropType in CropType.values) {
      add(TextButtonComponent(
        text: '${_getCropNameRu(cropType)} (${game.seedInventory[cropType]})',
        position: Vector2(buttonX, yOffset),
        onPressed: () => game.selectCropType(cropType),
        textRenderer: TextPaint(
          style: TextStyle(
            color: game.currentCropType == cropType ? Colors.yellow : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ));
      buttonX += 150;
      if (buttonX > size.x - 200) {
        buttonX = 50;
        yOffset += 30;
      }
    }
    yOffset += 50; // Отступ после кнопок выбора семян

    // Секция собранного урожая
    add(TextComponent(
      text: 'Собранный урожай:',
      position: Vector2(50, yOffset),
      textRenderer: TextPaint(style: const TextStyle(color: Colors.white, fontSize: 18)),
    ));
    yOffset += 30;

    game.harvestedCrops.forEach((type, count) {
      if (count > 0) {
        add(TextComponent(
          text: '${_getCropNameRu(type)}: $count',
          position: Vector2(50, yOffset),
          textRenderer: TextPaint(style: const TextStyle(color: Colors.white70, fontSize: 16)),
        ));
        yOffset += 20;
      }
    });
    if (game.harvestedCrops.values.every((count) => count == 0)) {
      add(TextComponent(
        text: 'Пока ничего не собрано.',
        position: Vector2(50, yOffset),
        textRenderer: TextPaint(style: const TextStyle(color: Colors.white70, fontSize: 16)),
      ));
    }
  }

  void _updateInventoryUI() {
    // Простой способ обновления - удалить и пересоздать элементы UI
    // В более сложных случаях можно обновлять только нужные TextComponent'ы
    _createInventoryUI();
  }

  String _getCropNameRu(CropType cropType) {
    switch (cropType) {
      case CropType.wheat:
        return 'Пшеница';
      case CropType.carrot:
        return 'Морковь';
      case CropType.cabbage:
        return 'Капуста';
      case CropType.onion:
        return 'Лук';
      case CropType.potato:
        return 'Картофель';
    }
  }
}
