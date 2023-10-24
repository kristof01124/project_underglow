import 'dart:developer';

import 'package:learning_dart/library/ArduinoNetwork/message.dart';
import 'package:learning_dart/library/ArduinoNetwork/message_router.dart';
import 'package:learning_dart/library/ArduinoNetwork/network_entity.dart';
import 'Network_debugger.dart';

class NetworkManager {
  static List<NetworkDebugger> debuggers = [];

  static List<NetworkEntity> switches = [];
  static Map<IP, NetworkEntity> backgroundDaemons = {}, advertisedEntities = {};

  static const int protocol = 1;
  static const IP messageRouterIp = IP(0, 0);
  static const IP backGroundDaemonMaxIP = IP(0, 255);
  static const IP advertisedEntityMinIP = IP(1, 0);
  static const IP advertisedEntityMaxIP = IP(254, 255);
  static const IP switchIP = IP(255, 0);
  static const IP broadcastIP = IP(255, 255);
  static const IP localBroadcastIP = IP(255, 254);

  static void looptask() async {
    while (true) {
      handle();
      await Future.delayed(const Duration());
    }
  }

  static void initialize() {
    for (var entity in advertisedEntities.values) {
      entity.initialize();
    }
    for (var entity in backgroundDaemons.values) {
      entity.initialize();
    }
    for (var entity in switches) {
      entity.initialize();
    }
    looptask();
  }

  static void handle() {
    for (var entity in advertisedEntities.values) {
      entity.handle();
    }
    for (var entity in backgroundDaemons.values) {
      entity.handle();
    }
    for (var entity in switches) {
      entity.handle();
    }
  }

  static void handleMessage(List<int> buffer, NetworkEntity src) {
    for (var debugger in debuggers) {
      debugger.digestMesssage(buffer);
    }
    MessageHeader header = MessageHeader();
    header.build(buffer);
    if (MessageRouter.getNumberOfHops(header.source) < header.numberOfHops) {
      log("Message is discarded, because it didnt come from the optimal path");
      return;
    }
    IP destination = header.destination;
    if (destination == src.getIp() || destination == broadcastIP) {
      routeMessage(buffer, src, header);
      return;
    }
    if (advertisedEntities.containsKey(destination)) {
      advertisedEntities[destination]?.handleMessage(buffer, src);
      return;
    }
    if (backgroundDaemons.containsKey(destination)) {
      backgroundDaemons[destination]?.handleMessage(buffer, src);
      return;
    }
    if (destination == localBroadcastIP) {
      localBroadcastMessage(buffer, src);
      return;
    }
    routeMessage(buffer, src, header);
  }

  static void routeMessage(
      List<int> buffer, NetworkEntity src, MessageHeader header) {
    header.setup(header.sizeOfPayload);
    buffer.setAll(0, header.buildBuffer());
    if (header.destination == broadcastIP) {
      broadcastMessage(buffer, src);
      return;
    }
    if (header.destination == src.getIp()) {
      outsideBroadcastMessage(buffer, src);
      return;
    }
    backgroundDaemons[messageRouterIp]?.handleMessage(buffer, src);
  }

  static void broadcastMessage(List<int> buffer, NetworkEntity src) {
    outsideBroadcastMessage(buffer, src);
    localBroadcastMessage(buffer, src);
  }

  static void localBroadcastMessage(List<int> buffer, NetworkEntity src) {
    for (var entity in advertisedEntities.values) {
      send(buffer, src, entity);
    }
    for (var entity in backgroundDaemons.values) {
      send(buffer, src, entity);
    }
  }

  static void outsideBroadcastMessage(List<int> buffer, NetworkEntity src) {
    for (var entity in switches) {
      send(buffer, src, entity);
    }
  }

  static void send(List<int> buffer, NetworkEntity src, NetworkEntity dst) {
    if (src != dst) {
      dst.handleMessage(buffer, src);
    }
  }

  static void addEntity(NetworkEntity entity) {
    if (entity.getIp().value <= backGroundDaemonMaxIP.value) {
      backgroundDaemons[entity.getIp()] = entity;
    }
    if (entity.getIp().value >= advertisedEntityMinIP.value &&
        entity.getIp().value <= advertisedEntityMaxIP.value) {
      advertisedEntities[entity.getIp()] = entity;
    }
    if (entity.getIp() == switchIP) {
      switches.add(entity);
    }
  }

  static void removeEntity(NetworkEntity entity) {
    if (entity.getIp().value <= backGroundDaemonMaxIP.value) {
      backgroundDaemons.remove(entity.getIp());
    }
    if (entity.getIp().value >= advertisedEntityMinIP.value &&
        entity.getIp().value <= advertisedEntityMaxIP.value) {
      advertisedEntities.remove(entity.getIp());
    }
    if (entity.getIp() == switchIP) {
      switches.remove(entity);
    }
  }

  static void attachDebugger(NetworkDebugger debugger) {
    debuggers.add(debugger);
  }

  get getAdvertisedEntities => advertisedEntities;
}
