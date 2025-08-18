import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';

import 'package:farmwow/game/farm_game.dart';

void main() {
  testWidgets('Farm Game smoke test', (WidgetTester tester) async {
    // Создаем экземпляр игры
    final farmGame = FarmGame();

    // Ждем загрузки игры
    await farmGame.onLoad();

    // Отображаем GameWidget с экземпляром игры
    await tester.pumpWidget(GameWidget(game: farmGame));

    // Проверяем, что GameWidget отображается
    expect(find.byType(GameWidget<FarmGame>), findsOneWidget);
  });
}