// lib/components/farm_tile.dart
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

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
  tomato,    // Помидор
}

class FarmTile extends RectangleComponent with HasGameRef, TapCallbacks {
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
    CropType.tomato: 20,  // 20 секунд
  };

  FarmTile({required this.gridX, required this.gridY})
      : super(
          position: Vector2(gridX * tileSize, gridY * tileSize),
          size: Vector2.all(tileSize),
          // paint: Paint()..color = Colors.green.shade300, // Убрали начальный сплошной цвет
        );

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
    Color color;
    
    switch (_state) {
      case TileState.grass:
        color = Colors.transparent; // Сделали траву прозрачной, чтобы было видно фон
        break;
      case TileState.tilled:
        color = Colors.brown.shade400;
        break;
      case TileState.planted:
        // Красный если нужно поливать
        color = _needsWater ? Colors.red.shade300 : Colors.brown.shade600;
        break;
      case TileState.watered:
        color = Colors.blue.shade300; // Синий = полито
        break;
      case TileState.grown:
        color = _getCropColor();
        break;
    }
    
    paint.color = color;
  }

  Color _getCropColor() {
    switch (_cropType) {
      case CropType.wheat:
        return Colors.yellow.shade600; // Спелая пшеница
      case CropType.carrot:
        return Colors.orange.shade600; // Морковь
      case CropType.tomato:
        return Colors.red.shade600; // Помидор
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
        // Сажаем пшеницу (по умолчанию)
        _plantCrop(CropType.wheat);
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
    _cropType = cropType;
    _state = TileState.planted;
    _growthProgress = 0.0;
    _plantedTime = DateTime.now();
    _wateredTime = DateTime.now(); // Сразу "полито"
    _needsWater = false;
    
    print('Посажена ${cropType.name} на ($gridX, $gridY)');
  }

  void _waterCrop() {
    if (_state != TileState.planted) return;
    
    _state = TileState.watered;
    _wateredTime = DateTime.now();
    _needsWater = false;
    
    print('Полито! ($gridX, $gridY)');
  }

  void _harvestCrop() {
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