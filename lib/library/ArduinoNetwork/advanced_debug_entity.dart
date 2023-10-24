import 'dart:developer';

import 'package:learning_dart/library/ArduinoNetwork/global_value_store.dart';
import 'package:learning_dart/library/ArduinoNetwork/message.dart';
import 'package:learning_dart/library/ArduinoNetwork/message_router.dart';
import 'package:learning_dart/library/ArduinoNetwork/network_clock.dart';
import 'package:learning_dart/library/ArduinoNetwork/network_entity.dart';
import 'package:learning_dart/library/ArduinoNetwork/network_manager.dart';

enum AdvancedDebugEntityMessageTypes { discoverMessage, discoverResponse }

typedef AdvancedDebugEntityDiscoverMessage = NetworkMessage<EmptyMessage>;
typedef AdvancedDebugEntityDiscoverResponse = NetworkMessage<EmptyMessage>;

class AdvancedDebugEntity extends NetworkEntity {
  IP ip;

  List<IP> testIps;

  Map<IP, bool> testResults = {};

  static const int messagePrimaryType = 100;

  static AdvancedDebugEntityDiscoverMessage createDiscoverMessage(
      {required IP source, required IP destination}) {
    return AdvancedDebugEntityDiscoverMessage(
      MessageHeader(
        source: source,
        destination: destination,
        messageType: MessageType(messagePrimaryType,
            AdvancedDebugEntityMessageTypes.discoverMessage.index),
      ),
      EmptyMessage(),
    );
  }

  static AdvancedDebugEntityDiscoverResponse createDiscoverResponse(
      {required IP source, required IP destination}) {
    return AdvancedDebugEntityDiscoverResponse(
      MessageHeader(
        source: source,
        destination: destination,
        messageType: MessageType(messagePrimaryType,
            AdvancedDebugEntityMessageTypes.discoverResponse.index),
      ),
      EmptyMessage(),
    );
  }

  void handleDiscoverMessage(
      List<int> buffer, NetworkEntity src, MessageHeader header) {
    NetworkManager.handleMessage(
        createDiscoverResponse(
                source: getIp(), destination: NetworkManager.broadcastIP)
            .buildBuffer(),
        this);
  }

  void handleDiscoverResponse(
      List<int> buffer, NetworkEntity src, MessageHeader header) {
    if (testIps.contains(header.source)) {
      testResults[header.source] = true;
    }
  }

  @override
  void handle() {}

  @override
  void handleMessage(List<int> buffer, NetworkEntity src) {
    MessageHeader header = MessageHeader();
    header.build(buffer);
    if (header.messageType ==
        MessageType(messagePrimaryType,
            AdvancedDebugEntityMessageTypes.discoverMessage.index)) {
      handleDiscoverMessage(buffer, src, header);
    }
    if (header.messageType ==
        MessageType(messagePrimaryType,
            AdvancedDebugEntityMessageTypes.discoverResponse.index)) {
      handleDiscoverResponse(buffer, src, header);
    }
  }

  @override
  IP getIp() {
    return ip;
  }

  AdvancedDebugEntity(this.ip, this.testIps) {
    for (IP ip in testIps) {
      testResults[ip] = false;
    }
  }

  void pingEntities() {
    NetworkManager.handleMessage(
        createDiscoverMessage(
          source: ip,
          destination: NetworkManager.broadcastIP,
        ).buildBuffer(),
        this);
  }

  void printPingResults() {
    log("-----------------------------------");
    log("Printing the results for the advanced debug entity with ip: ${ip.primaryValue}.${ip.secondaryValue}");
    for (var value in testResults.entries) {
      log("IP: ${value.key.primaryValue}.${value.key.secondaryValue}, results: ${value.value}");
    }
  }

  static void printMessageHeaderData(List<int> buffer) {
    MessageHeader header = MessageHeader();
    header.build(buffer);
    log("Digesting a message!\n"
        "source: ${header.source.primaryValue}.${header.source.secondaryValue}\n"
        "Destination: ${header.destination.primaryValue}.${header.destination.secondaryValue}\n"
        "Message type: ${header.messageType.primaryValue} ${header.messageType.secondaryValue}\n"
        "Checksum: ${header.checksum}\n"
        "Number of hops: ${header.numberOfHops}\n"
        "Size of payload: ${header.sizeOfPayload}"
        "----------------------------------------------------------------------");
  }

  static void printSyncedTime() {
    log("-------------------------------------------------------");
    log("Time in nc: ${NetworkClock.millis()}");
  }

  static void printAllAvailableGVSValues() {
    log("-----------------------------------------------");
    log("Printing all available values in gvs");
    for (var value in GlobalValueStore.getAllChangedValues()) {
      log("ID: ${value.index}, value: ${value.value}");
    }
  }

  static void printAllAvailableRoutes() {
    log("-------------------------------------------------");
    log("printing all available routes in the MeR");
    for (var record in MessageRouter.routingRecords.entries) {
      log(
        "Entity with ip of ${record.key.primaryValue}.${record.key.secondaryValue}"
        "going through entity with ip of ${record.value.destinationEntity.getIp().primaryValue}.${record.value.destinationEntity.getIp().secondaryValue}"
        "through ${record.value.numberOfHops} hops",
      );
    }
  }
}
