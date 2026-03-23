import 'dart:async';

import 'package:flutter/material.dart';

import '../models/light.dart';
import '../services/firebase_service.dart';
import '../services/shared_prefs_service.dart';

class LightProvider extends ChangeNotifier {
  List<Light> lights = [];
  bool loading = true;
  String searchQuery = '';

  String selectedRoom = 'All Rooms';
  bool globalAutoMode = true;
  bool motionDetected = false;
  int inactivitySeconds = 30;
  Timer? _inactivityTimer;
  int _currentSeconds = 0;
  int get currentSeconds => _currentSeconds;
  double energySaved = 24.5;

  final FirebaseService _service = FirebaseService();
  late StreamSubscription<List<Light>> _subscription;

  LightProvider() {
    _loadSettings();
    initStream();
  }

  Future<void> _loadSettings() async {
    final settings = await SharedPrefsService.loadSettings();
    inactivitySeconds = settings['inactivitySeconds'];
    costPerKwh = settings['costPerKwh'];
    notifyListeners();
  }

  void setInactivitySeconds(int seconds) {
    inactivitySeconds = seconds;
    _saveSettings();
    notifyListeners();
  }

  void setCostPerKwh(double cost) {
    costPerKwh = cost;
    _saveSettings();
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    await SharedPrefsService.saveSettings(
      inactivitySeconds: inactivitySeconds,
      costPerKwh: costPerKwh,
    );
  }

  List<Light> get filteredLights {
    if (searchQuery.isEmpty) return lights;
    final q = searchQuery.toLowerCase();
    return lights.where((light) {
      return light.name.toLowerCase().contains(q) ||
          light.room.toLowerCase().contains(q) ||
          light.arduinoIp.toLowerCase().contains(q);
    }).toList();
  }

  Map<String, List<Light>> get roomLights {
    final map = <String, List<Light>>{};
    for (final light in lights) {
      map.putIfAbsent(light.room, () => []).add(light);
    }
    return map;
  }

  List<Light> getRoomLights(String room) => room == 'All Rooms' ? lights : roomLights[room] ?? [];

  List<Light> getOverheadLights(String room) => getRoomLights(room).where((l) => l.lightType == LightType.overhead).toList();

  List<Light> getBacklights(String room) => getRoomLights(room).where((l) => l.lightType == LightType.backlight).toList();

  List<String> get uniqueRooms {
    return lights.map((light) => light.room).toSet().toList();
  }

  void setSelectedRoom(String room) {
    selectedRoom = room;
    notifyListeners();
  }

  void toggleGlobalAutoMode() {
    globalAutoMode = !globalAutoMode;
    notifyListeners();
    if (!globalAutoMode) {
      _inactivityTimer?.cancel();
      motionDetected = false;
      _currentSeconds = 0;
      notifyListeners();
    }
  }

  void simulateMotion() {
    motionDetected = true;
    notifyListeners();
    if (globalAutoMode) {
      final roomLights = getRoomLights(selectedRoom);
      for (final light in roomLights) {
        toggleLight(light);
      }
      startInactivityTimer();
    }
    Future.delayed(const Duration(seconds: 2), () {
      motionDetected = false;
      if (globalAutoMode) {
        turnOffRoomLights(selectedRoom);
      }
      notifyListeners();
    });
  }

  void startInactivityTimer() {
    _inactivityTimer?.cancel();
    _currentSeconds = inactivitySeconds;
    notifyListeners();

    _inactivityTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentSeconds--;
      notifyListeners();
      if (_currentSeconds <= 0) {
        turnOffRoomLights(selectedRoom);
        timer.cancel();
      }
    });
  }

  void turnOffRoomLights(String room) {
    final roomLights = getRoomLights(room);
    for (final light in roomLights) {
      if (light.state == 'on') {
        toggleLight(light);
      }
    }
    motionDetected = false;
    _currentSeconds = 0;
    notifyListeners();
  }

  void initStream() {
    _subscription = _service.getLights().listen((lightsList) {
      lights = lightsList;
      loading = false;
      notifyListeners();
    });
  }

  Future<void> _updateLocalLight(Light updated) async {
    final idx = lights.indexWhere((element) => element.id == updated.id);
    if (idx >= 0) {
      lights[idx] = updated;
      notifyListeners();
    }
  }

  Future<void> toggleLight(Light light) async {
    final newState = light.state == 'on' ? 'off' : 'on';
    final cand = light.copyWith(state: newState);
    await _updateLocalLight(cand);

    try {
      await _service.updateLight(light.id, {'state': newState});
    } catch (e) {
      final revert = light.copyWith(state: light.state);
      await _updateLocalLight(revert);
      debugPrint('toggleLight failed: $e');
    }
  }

  Future<void> setDim(Light light, int level) async {
    final cand = light.copyWith(dimLevel: level);
    await _updateLocalLight(cand);

    try {
      await _service.updateLight(light.id, {'dimLevel': level});
    } catch (e) {
      await _updateLocalLight(light);
      debugPrint('setDim failed: $e');
    }
  }

  Future<void> addLight(Light light) async {
    await _service.addLight(light);
  }

  Future<void> updateLight(Light light) async {
    await _service.updateLight(light.id, light.toJson());
  }

  Future<void> deleteLight(Light light) async {
    await _service.deleteLight(light.id);
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    _subscription.cancel();
    super.dispose();
  }

  double costPerKwh = 12.0;
  double get totalCostSaved => energySaved * costPerKwh;
}
