import 'package:flutter/material.dart';
import 'package:flame/game.dart';

void main() {
  runApp(GameWidget(game: FarmGame()));
}

class FarmGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    print('FarmGame loaded');
    // Здесь будет логика загрузки ассетов и инициализации
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Здесь будет рисование элементов игры
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Здесь будет логика обновления игры
  }
}
