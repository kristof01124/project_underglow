import 'package:learning_dart/library/ArduinoNetwork/network_entity.dart';


class NetworkManager {
  static List<NetworkEntity> switches = [],
      backgroundDaemons = [],
      advertisedEntities = [];

  static late NetworkEntity messageRouter;

  static const int protocol = 1;

  static void handleMessage(List<int> buffer, NetworkEntity src) {
    messageRouter.handleMessage(buffer, src);
  }

  static void initialize() {
    messageRouter.initialize();
    for (NetworkEntity entity in advertisedEntities) {
      entity.initialize();
    }
    for (NetworkEntity entity in switches) {
      entity.initialize();
    }
    for (NetworkEntity entity in backgroundDaemons) {
      entity.initialize();
    }
  }

  static void handle() {
    messageRouter.handle();
    for (NetworkEntity entity in advertisedEntities) {
      entity.handle();
    }
    for (NetworkEntity entity in switches) {
      entity.handle();
    }
    for (NetworkEntity entity in backgroundDaemons) {
      entity.handle();
    }
  }

  static void addBackgroundDaemon(NetworkEntity entity) {
    backgroundDaemons.add(entity);
  }

  static void addSwitch(NetworkEntity entity) {
    switches.add(entity);
  }

  static void addAdvertisedEntity(NetworkEntity entity) {
    advertisedEntities.add(entity);
  }
}
