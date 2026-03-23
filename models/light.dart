enum LightType { overhead, backlight, other }

class Light {
  final String id;
  final String name;
  final String room;
  final String arduinoIp;
  final int pin;
  final String state;
  final int dimLevel;
  final LightType? lightType;
  final bool isAutoEnabled;

  Light({
    required this.id,
    required this.name,
    required this.room,
    required this.arduinoIp,
    required this.pin,
    required this.state,
    required this.dimLevel,
    this.lightType,
    this.isAutoEnabled = true,
  });

  factory Light.fromJson(Map<String, dynamic> json) {
    String nonNullString(List<String> keys, [String defaultValue = '']) {
      for (final key in keys) {
        if (json.containsKey(key) && json[key] != null) {
          return json[key].toString();
        }
      }
      return defaultValue;
    }

    int nonNullInt(List<String> keys, [int defaultValue = 0]) {
      for (final key in keys) {
        if (json.containsKey(key) && json[key] != null) {
          final value = json[key];
          if (value is int) return value;
          if (value is String) return int.tryParse(value) ?? defaultValue;
          if (value is double) return value.toInt();
        }
      }
      return defaultValue;
    }

    return Light(
      id: nonNullString(['id', 'ID', '_id']),
      name: nonNullString(['name', 'Name']),
      room: nonNullString(['room', 'Room']),
      arduinoIp: nonNullString([
        'arduinoIp',
        'Arduinoip',
        'ArduinoIp',
        'arduino_ip',
      ]),
      pin: nonNullInt(['pin']),
      state: nonNullString(['state', 'State'], 'off'),
      dimLevel: nonNullInt(['dimLevel', 'dim_level']),
      lightType: _parseLightType(json),
      isAutoEnabled: json['isAutoEnabled'] as bool? ?? true,
    );
  }

  static LightType? _parseLightType(Map<String, dynamic> json) {
    final typeStr = json['lightType']?.toString().toLowerCase();
    switch (typeStr) {
      case 'overhead':
        return LightType.overhead;
      case 'backlight':
        return LightType.backlight;
      default:
        return null;
    }
  }

  Light copyWith({
    String? id,
    String? name,
    String? room,
    String? arduinoIp,
    int? pin,
    String? state,
    int? dimLevel,
    LightType? lightType,
    bool? isAutoEnabled,
  }) {
    return Light(
      id: id ?? this.id,
      name: name ?? this.name,
      room: room ?? this.room,
      arduinoIp: arduinoIp ?? this.arduinoIp,
      pin: pin ?? this.pin,
      state: state ?? this.state,
      dimLevel: dimLevel ?? this.dimLevel,
      lightType: lightType ?? this.lightType,
      isAutoEnabled: isAutoEnabled ?? this.isAutoEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'room': room,
      'arduinoIp': arduinoIp,
      'pin': pin,
      'state': state,
      'dimLevel': dimLevel,
      if (lightType != null) 'lightType': lightType.toString().split('.').last,
      'isAutoEnabled': isAutoEnabled,
    };
  }
}
