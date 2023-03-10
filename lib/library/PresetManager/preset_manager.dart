import '../ArduinoNetwork/message.dart';

const String defaultPresetName = '[None]';

class Preset {
  final String name;
  final List<Message>? messages;

  Preset({this.name = defaultPresetName, this.messages});
}

class PresetManager {
  List<Preset> presets = [];

  List<Preset> getPresets() {
    return presets;
  }
}
