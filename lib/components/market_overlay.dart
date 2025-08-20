import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../game/farm_game.dart';
import '../components/farm_tile.dart'; // Для CropType
import '../components/text_button_component.dart';

class MarketOverlay extends PositionComponent with TapCallbacks, HasGameRef<FarmGame> {
  final FarmGame game;

  MarketOverlay({required this.game, required Vector2 position, required Vector2 size})
      : super(position: position, size: size) {
    priority = 100;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _createMarketUI();
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Обновляем UI рынка в каждом кадре, чтобы отображать актуальные данные (монеты, количество семян)
    _updateMarketUI();
  }

  void _createMarketUI() {
    // Очищаем все дочерние компоненты перед перерисовкой, чтобы избежать дублирования
    removeAll(children);

    // Фон оверлея
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black.withOpacity(0.7),
    ));

    // Контейнер для содержимого рынка
    final panelWidth = size.x * 0.8;
    final panelHeight = size.y * 0.8;
    final panelPositionX = (size.x - panelWidth) / 2;
    final panelPositionY = (size.y - panelHeight) / 2;

    add(RectangleComponent(
      position: Vector2(panelPositionX, panelPositionY),
      size: Vector2(panelWidth, panelHeight),
      paint: Paint()..color = Colors.blueGrey.shade900,
    ));

    // Заголовок рынка
    add(TextComponent(
      text: 'МАГАЗИН СЕМЯН',
      position: Vector2(panelPositionX + 20, panelPositionY + 20),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));

    // Отображение текущих монет
    add(TextComponent(
      text: 'Монеты: \$${game.coins}',
      position: Vector2(panelPositionX + 20, panelPositionY + 60),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.amberAccent,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));

    // Кнопка закрытия
    add(TextButtonComponent(
      text: 'ЗАКРЫТЬ',
      position: Vector2(panelPositionX + panelWidth - 100, panelPositionY + 20),
      onPressed: game.closeMarket,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));

    // Список семян для покупки
    double startY = panelPositionY + 100;
    game.seedPrices.forEach((cropType, price) {
      add(TextComponent(
        text: '\$${_getCropNameRu(cropType)}: $price монет',
        position: Vector2(panelPositionX + 20, startY),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ));

      // Кнопка Купить
      add(TextButtonComponent(
        text: 'КУПИТЬ (x1)',
        position: Vector2(panelPositionX + panelWidth - 150, startY - 5), // Подгоняем позицию
        onPressed: () {
          game.buySeed(cropType, 1);
        },
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.lightGreenAccent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ));
      startY += 40; // Смещение для следующей строки
    });
  }

  // Просто пересоздаем UI для обновления, можно оптимизировать в будущем
  void _updateMarketUI() {
    _createMarketUI();
  }

  String _getCropNameRu(CropType cropType) {
    switch (cropType) {
      case CropType.wheat: return 'Пшеница';
      case CropType.carrot: return 'Морковь';
      case CropType.cabbage: return 'Капуста';
      case CropType.onion: return 'Лук';
      case CropType.potato: return 'Картофель';
    }
  }
}
