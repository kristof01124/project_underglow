import 'package:learning_dart/library/ArduinoNetwork/network_entity.dart';
import 'package:learning_dart/library/ArduinoNetwork/network_manager.dart';

import '../ArduinoNetwork/message.dart';

const String defaultPresetName = '[None]';

class PresetManager extends NetworkEntity {
  static Map<String, List<Message>> presets = {
    'Fill': [],
    'Rgb wave': [],
    'Somethin': [],
    'I guess': [],
  };
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

  // These functions don't need to be ovewritten, the only reason the PresetManager
  // needs to inherit from networkentity is to send messages
  @override
  void handle() {}

  @override
  void handleMessage(List<int> buffer, NetworkEntity src) {}
}
