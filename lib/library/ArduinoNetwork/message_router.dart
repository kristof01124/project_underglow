import 'dart:developer';

import 'package:learning_dart/library/ArduinoNetwork/network_clock.dart';
import 'package:learning_dart/library/ArduinoNetwork/network_manager.dart';
import 'package:learning_dart/library/ArduinoNetwork/message.dart';
import 'package:learning_dart/library/ArduinoNetwork/network_entity.dart';

class RoutingRecord {
  final int numberOfHops;
  final NetworkEntity destinationEntity;
  final int timeOfCreation;

  RoutingRecord({
    this.numberOfHops = 0,
    required this.destinationEntity,
    required this.timeOfCreation,
  });
}

class MessageRouterRecordUpdate extends SegmentMessage {
  MessageRouterRecordUpdate({
    IP ipOfDevice = const IP(0, 0),
    int numberOfHops = 0,
  }) {
    add("ipOfDevice", IpMessageData(ipOfDevice));
    add("numberOfHops", MessageUint8(numberOfHops));
  }

  IP get ipOfDevice => (segments["ipOfDevice"] as IpMessageData).value;
  int get numberOfHops => (segments["numberOfHops"] as MessageUint8).value;
}

enum MessageRouterMessageTypes {
  updateMessage,
  updateRequest,
}

typedef MessageRouterUpdateMessage = NetworkMessage<ListMessage>;
typedef MessageRouterUpdateRequest = NetworkMessage<EmptyMessage>;

class MessageRouter extends NetworkEntity {
  int messagePrimaryType = 0;
  MessageRouterUpdateMessage createMessageRouterUpdateMessage(
      {IP source = const IP(0, 0),
      Map<IP, RoutingRecord> advertisedRecords = const {}}) {
    return MessageRouterUpdateMessage(
        MessageHeader(
          source: source,
          destination: source,
          messageType: MessageType(messagePrimaryType,
              MessageRouterMessageTypes.updateMessage.index),
        ),
        ListMessage((size) => List.filled(size, MessageRouterRecordUpdate()),
            data: createListFromAdvertisedRecords(advertisedRecords)));
  }

  MessageRouterUpdateRequest createMessageRouterUpdateRequest(
      {IP source = const IP(0, 0)}) {
    return MessageRouterUpdateRequest(
      MessageHeader(
          source: source,
          destination: source,
          messageType: MessageType(
            messagePrimaryType,
            MessageRouterMessageTypes.updateRequest.index,
          )),
      EmptyMessage(),
    );
  }

  void handleMeRUpdateMessage(
      List<int> buffer, NetworkEntity src, MessageHeader header) {
    MessageRouterUpdateMessage update = createMessageRouterUpdateMessage();
    update.build(buffer);
    Map<IP, RoutingRecord> changed = {};
    for (var value in update.second.data) {
      var update = (value as MessageRouterRecordUpdate);
      log("Got an mer update (IP:${value.ipOfDevice.primaryValue}.${value.ipOfDevice.secondaryValue}, number of hops:${value.numberOfHops})");
      if (isBetter(update)) {
        RoutingRecord newRecord = RoutingRecord(
          destinationEntity: src,
          timeOfCreation: DateTime.now().millisecondsSinceEpoch,
          numberOfHops: update.numberOfHops,
        );
        changed[update.ipOfDevice] = newRecord;
        routingRecords[update.ipOfDevice] = newRecord;
      }
    }
    if (changed.isNotEmpty) {
      NetworkManager.handleMessage(
          createMessageRouterUpdateMessage(
            source: getIp(),
            advertisedRecords: changed,
          ).buildBuffer(),
          this);
    }
  }

  void handleUpdateRequestMessage(
      List<int> buffer, NetworkEntity src, MessageHeader header) {
    src.handleMessage(
        createMessageRouterUpdateMessage(
          advertisedRecords: routingRecords,
          source: getIp(),
        ).buildBuffer(),
        this);
  }

  void handleSyncNotification(
      List<int> buffer, NetworkEntity src, MessageHeader header) {
    NetworkManager.handleMessage(
      createMessageRouterUpdateMessage(
        advertisedRecords: routingRecords,
        source: getIp(),
      ).buildBuffer(),
      this,
    );
    NetworkManager.handleMessage(
      createMessageRouterUpdateRequest(
        source: getIp(),
      ).buildBuffer(),
      this,
    );
  }

  void routeMessage(List<int> buffer, NetworkEntity src, MessageHeader header) {
    routingRecords[header.destination]
        ?.destinationEntity
        .handleMessage(buffer, src);
  }

  static Map<IP, RoutingRecord> routingRecords = {};

  bool isBetter(MessageRouterRecordUpdate newRecord) {
    return (!routingRecords.containsKey(newRecord.ipOfDevice) ||
        ((routingRecords[newRecord.ipOfDevice]?.numberOfHops ?? 0) >
            newRecord.numberOfHops));
  }

  List<MessageRouterRecordUpdate> createListFromAdvertisedRecords(
      Map<IP, RoutingRecord> advertisedRecords) {
    var out = <MessageRouterRecordUpdate>[];
    advertisedRecords.forEach(
      (key, value) {
        out.add(
          MessageRouterRecordUpdate(
              ipOfDevice: key, numberOfHops: value.numberOfHops),
        );
      },
    );
    return out;
  }

  get getRoutingRecords => routingRecords;

  @override
  void handleMessage(List<int> buffer, NetworkEntity src) {
    MessageHeader header = MessageHeader();
    header.build(buffer);
    reinforceRecord(header, src);
    if (header.messageType ==
        MessageType(
          messagePrimaryType,
          MessageRouterMessageTypes.updateMessage.index,
        )) {
      handleMeRUpdateMessage(buffer, src, header);
      return;
    }
    if (header.messageType ==
        MessageType(
          messagePrimaryType,
          MessageRouterMessageTypes.updateRequest.index,
        )) {
      handleMeRUpdateMessage(buffer, src, header);
      return;
    }

    if (header.messageType ==
        MessageType(
          NetworkClock.messagePrimaryType,
          NetworkClockMessageTypes.syncNotification.index,
        )) {
      handleSyncNotification(buffer, src, header);
      return;
    }
    routeMessage(buffer, src, header);
  }

  @override
  void initialize() {
    routingRecords.clear();
    for (var value in NetworkManager.advertisedEntities.values) {
      routingRecords[value.getIp()] = RoutingRecord(
          destinationEntity: value,
          timeOfCreation: DateTime.now().millisecondsSinceEpoch);
    }
  }

  @override
  IP getIp() {
    return const IP(0, 0);
  }

  void reinforceRecord(MessageHeader header, NetworkEntity src) {
    if (!isBetter(MessageRouterRecordUpdate(
      ipOfDevice: src.getIp(),
      numberOfHops: header.numberOfHops,
    ))) {
      return;
    }
    routingRecords[header.source] = RoutingRecord(
      destinationEntity: src,
      timeOfCreation: DateTime.now().millisecondsSinceEpoch,
      numberOfHops: header.numberOfHops,
    );
  }

  static int getNumberOfHops(IP ip) {
    return routingRecords[ip]?.numberOfHops ?? 255;
  }
}
