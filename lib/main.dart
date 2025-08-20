import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/farm_game.dart'; // 


void main() {
  runApp(GameWidget(
    game: FarmGame(),
    // Добавляем экран загрузки
    loadingBuilder: (context) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: Text(
            'Загрузка... ⏳',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      );
    },
  ));
}