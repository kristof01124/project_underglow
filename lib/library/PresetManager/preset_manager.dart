import 'package:learning_dart/library/ArduinoNetwork/network_entity.dart';
import 'package:learning_dart/library/ArduinoNetwork/network_manager.dart';

import '../ArduinoNetwork/message.dart';

const String defaultPresetName = '[None]';

class PresetManager extends NetworkEntity {
  static Map<String, List<Message>> presets = {};
  static PresetManager instance = PresetManager();
  static List<String> menuPresets = [
    for (int i = 0; i < 6; i++) defaultPresetName
  ];
  // These are the presets that are shown in the menu

  static List<String> getPresets() {
    return presets.keys.toList();
  }

  static void run(String presetName) {
    List<Message> messages = presets[presetName] ?? [];
    for (Message msg in messages) {
      NetworkManager.handleMessage(msg.buildBuffer(), instance);
    }
  }

  @override
  void handle() {
    // TODO: implement handle
  }

  @override
  void handleMessage(List<int> buffer, NetworkEntity src) {
    // TODO: implement handleMessage
  }
}
