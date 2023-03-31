import 'package:learning_dart/library/ArduinoNetwork/network_entity.dart';

import 'message.dart';

class NetworkManager {
  static const IP phoneIP = IP(10);
  static const int protocol = 1;

  static late NetworkEntity messageRouter;

  static List<NetworkEntity> entities = [];

  static void handleMessage(List<int> buffer, NetworkEntity src) {
    messageRouter.handleMessage(buffer, src);
  }

  static void initialize() {
    for (NetworkEntity entity in entities) {
      entity.initialize();
    }
  }

  static void handle() {
    messageRouter.handle();
    for (var entity in entities) {
      entity.handle();
    }
  }

  static void addEntity(NetworkEntity entity) {
    entities.add(entity);
    messageRouter.initialize();
  }
}
