// lib/components/farm_tile.dart
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../game/farm_game.dart'; // Добавили импорт FarmGame

enum TileState {
  grass,     // Трава (пустой тайл)
  tilled,    // Вспахан (грядка готова)
  planted,   // Посажено семя
  watered,   // Полито
  grown,     // Выросло (готово к сбору)
}

enum CropType {
  wheat,     // Пшеница
  carrot,    // Морковь
  cabbage,   // Капуста
  onion,     // Лук
  potato,    // Картофель
}

class FarmTile extends RectangleComponent with HasGameRef, TapCallbacks {
  late Sprite _tilledSprite;
  late Map<CropType, Sprite> _grownSprites;
  late Map<CropType, Sprite> _seedSprites;
  TileState _state = TileState.grass;
  CropType? _cropType;
  double _growthProgress = 0.0;
  DateTime? _plantedTime;
  DateTime? _wateredTime;
  bool _needsWater = false;
  
  final int gridX;
  final int gridY;
  static const double tileSize = 64.0;
  
  // Время роста разных культур (в секундах)
  static const Map<CropType, int> growthTimes = {
    CropType.wheat: 10,   // 10 секунд для теста
    CropType.carrot: 15,  // 15 секунд
    CropType.cabbage: 12, // Примерное время роста
    CropType.onion: 8,    // Примерное время роста
    CropType.potato: 18,  // Примерное время роста
  };

  FarmTile({required this.gridX, required this.gridY})
      : super(
          position: Vector2(gridX * tileSize, gridY * tileSize),
          size: Vector2.all(tileSize),
          // paint: Paint()..color = Colors.green.shade300, // Убрали начальный сплошной цвет
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _tilledSprite = await gameRef.loadSprite('tiles/bed1.png');
    
    _grownSprites = {};
    _seedSprites = {};
    
    for (var cropType in CropType.values) {
      _grownSprites[cropType] = await gameRef.loadSprite('planting/${cropType.name}.png');
      _seedSprites[cropType] = await gameRef.loadSprite('planting_seeds/${cropType.name}_seed.png');
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Обновляем рост растений
    if (_state == TileState.planted || _state == TileState.watered) {
      _updateGrowth();
    }
    
    // Обновляем визуал
    _updateVisuals();
  }

  void _updateGrowth() {
    if (_plantedTime == null || _cropType == null) return;
    
    final now = DateTime.now();
    final elapsedSeconds = now.difference(_plantedTime!).inSeconds;
    final totalGrowthTime = growthTimes[_cropType!]!;
    
    // Если полили - рост в 2 раза быстрее
    final growthMultiplier = _state == TileState.watered ? 2.0 : 1.0;
    final adjustedElapsed = elapsedSeconds * growthMultiplier;
    
    _growthProgress = (adjustedElapsed / totalGrowthTime).clamp(0.0, 1.0);
    
    // Проверяем нужно ли поливать (каждые 5 секунд)
    if (_state == TileState.planted && !_needsWater) {
      final timeSinceWatered = _wateredTime != null ? 
          now.difference(_wateredTime!).inSeconds : 999;
      _needsWater = timeSinceWatered > 5;
    }
    
    // Если выросло - меняем состояние
    if (_growthProgress >= 1.0) {
      _state = TileState.grown;
    }
  }

  void _updateVisuals() {
    // Удаляем все дочерние спрайты перед отрисовкой нового состояния
    // (если таковые были, чтобы избежать наложения)
    removeAll(children.whereType<SpriteComponent>());

    switch (_state) {
      case TileState.grass:
        paint.color = Colors.transparent; // Трава прозрачна
        break;
      case TileState.tilled:
        // Добавляем спрайт грядки
        add(SpriteComponent(sprite: _tilledSprite, size: size));
        paint.color = Colors.transparent; // Сделаем сам тайл прозрачным, чтобы видеть спрайт
        break;
      case TileState.planted:
        // Добавляем спрайт семени
        if (_cropType != null) {
          add(SpriteComponent(sprite: _seedSprites[_cropType!]!, size: size));
        }
        paint.color = _needsWater ? Colors.red.shade300 : Colors.transparent; // Красный если нужно поливать, иначе прозрачно
        break;
      case TileState.watered:
        // Добавляем спрайт семени (так как оно еще растет)
        if (_cropType != null) {
          add(SpriteComponent(sprite: _seedSprites[_cropType!]!, size: size));
        }
        paint.color = Colors.blue.shade300; // Синий = полито, но спрайт поверх
        break;
      case TileState.grown:
        // Добавляем спрайт выросшей культуры
        if (_cropType != null) {
          add(SpriteComponent(sprite: _grownSprites[_cropType!]!, size: size));
        }
        paint.color = Colors.transparent; // Сделаем сам тайл прозрачным, чтобы видеть спрайт
        break;
    }
  }

  Color _getCropColor() {
    switch (_cropType) {
      case CropType.wheat:
        return Colors.yellow.shade600; // Спелая пшеница
      case CropType.carrot:
        return Colors.orange.shade600; // Морковь
      case CropType.cabbage:
        return Colors.green.shade600; // Капуста
      case CropType.onion:
        return Colors.purple.shade600; // Лук
      case CropType.potato:
        return Colors.brown.shade600; // Картофель
      case null:
        return Colors.grey;
    }
  }

  @override
  bool onTapDown(TapDownEvent event) {
    _handleTap();
    return true;
  }

  void _handleTap() {
    switch (_state) {
      case TileState.grass:
        // Делаем грядку
        _state = TileState.tilled;
        print('Грядка готова на ($gridX, $gridY)');
        break;
        
      case TileState.tilled:
        // Сажаем выбранную культуру
        _plantCrop((gameRef as FarmGame).currentCropType);
        break;
        
      case TileState.planted:
        if (_needsWater) {
          // Поливаем
          _waterCrop();
        } else {
          print('Растение не нуждается в поливе');
        }
        break;
        
      case TileState.watered:
        print('Уже полито! Рост: ${(_growthProgress * 100).toInt()}%');
        break;
        
      case TileState.grown:
        // Собираем урожай
        _harvestCrop();
        break;
    }
  }

  void _plantCrop(CropType cropType) {
    // Проверяем наличие семян через FarmGame
    if ((gameRef as FarmGame).plantSeed(cropType)) {
      _cropType = cropType;
      _state = TileState.planted;
      _growthProgress = 0.0;
      _plantedTime = DateTime.now();
      _wateredTime = DateTime.now(); // Сразу "полито"
      _needsWater = false;
      
      print('Посажена ${cropType.name} на ($gridX, $gridY)');
    } else {
      print('Недостаточно семян ${cropType.name}!');
    }
  }

  void _waterCrop() {
    if (_state != TileState.planted) return;
    
    _state = TileState.watered;
    _wateredTime = DateTime.now();
    _needsWater = false;
    
    print('Полито! ($gridX, $gridY)');
  }

  void _harvestCrop() {
    if (_cropType == null) return; // Нечего собирать
    
    // Собираем урожай через FarmGame
    (gameRef as FarmGame).collectCrop(_cropType!); // Увеличиваем количество собранных культур
    print('Собран урожай ${_cropType?.name} с ($gridX, $gridY)!');
    
    // Возвращаем к траве
    _state = TileState.grass;
    _cropType = null;
    _growthProgress = 0.0;
    _plantedTime = null;
    _wateredTime = null;
    _needsWater = false;
  }

  // Геттеры для отладки
  String get stateString => _state.name;
  String get cropString => _cropType?.name ?? 'none';
  int get growthPercent => (_growthProgress * 100).toInt();
}