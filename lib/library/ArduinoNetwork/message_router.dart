import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:learning_dart/library/ArduinoNetwork/network_clock.dart';
import 'package:learning_dart/library/ArduinoNetwork/network_manager.dart';
import 'package:learning_dart/library/ArduinoNetwork/message.dart';
import 'package:learning_dart/library/ArduinoNetwork/network_entity.dart';

int ucharMax = 255;

class MessageRouterRecord {
  int numberOfHops;
  NetworkEntity destinationEntity;

  MessageRouterRecord({this.numberOfHops = 0, required this.destinationEntity});
}

class MessageRouterRecordUpdate extends SegmentMessage {
  MessageRouterRecordUpdate(
      {IP ipOfDevice = const IP(0), int numberOfHops = 0}) {
    add("ipOfDevice", IpMessageData(ipOfDevice));
    add("numberOfHops", MessageUint8(numberOfHops));
  }

  get ipOfDevice => (segments["ipOfDevice"] as IpMessageData).value;
  get numberOfHops => (segments["numberOfHops"] as MessageUint8).value;
}

enum MessageRouterMessageTypes {
  updateMessage,
  updateRequest,
}

typedef MessageRouterUpdateMessage = NetworkMessage<ListMessage>;
typedef MessageRouterUpdateRequest = NetworkMessage<EmptyMessage>;

class MessageRouter extends NetworkEntity {
  static const IP defautltIp = IP(0);
  static const IP broadcastIP = IP(255);
  static const IP localBroadcastIP = IP(254);

  int messagePrimaryType = 4;
  static IP messageRouterIp = const IP(1);

  MessageRouterUpdateMessage createMessageRouterUpdateMessage(
      {IP source = const IP(0),
      Map<IP, MessageRouterRecord> advertisedRecords = const {}}) {
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
      {IP source = const IP(0)}) {
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

  void handleUpdateMessage(
      List<int> buffer, NetworkEntity src, MessageHeader header) {
    MessageRouterUpdateMessage update = createMessageRouterUpdateMessage();
    update.build(buffer);
    Map<IP, MessageRouterRecord> updatedValues = {};
    for (var value in (update.second.data as List<MessageRouterRecordUpdate>)) {
      if (foundBetterDestinationEntity(
          MessageRouterRecord(
              destinationEntity: src, numberOfHops: value.numberOfHops),
          value.ipOfDevice)) {
        updatedValues[value.ipOfDevice] = MessageRouterRecord(
            destinationEntity: src, numberOfHops: value.numberOfHops);
      }
    }
    updatedValues.forEach((key, value) {
      routingRecords[key] = value;
    });
    if (updatedValues.isNotEmpty) {
      NetworkManager.handleMessage(
          createMessageRouterUpdateMessage(
                  source: messageRouterIp, advertisedRecords: updatedValues)
              .buildBuffer(),
          this);
    }
  }

  void handleUpdateRequestMessage(
      List<int> buffer, NetworkEntity src, MessageHeader header) {
    src.handleMessage(
        createMessageRouterUpdateMessage(
                advertisedRecords: routingRecords, source: messageRouterIp)
            .buildBuffer(),
        this);
  }

  void handleSyncNotification(
      List<int> buffer, NetworkEntity src, MessageHeader header) {
    NetworkManager.handleMessage(
      createMessageRouterUpdateMessage(
              advertisedRecords: routingRecords, source: messageRouterIp)
          .buildBuffer(),
      this,
    );
    NetworkManager.handleMessage(
      createMessageRouterUpdateRequest(source: messageRouterIp).buildBuffer(),
      this,
    );
  }

  Map<IP, MessageRouterRecord> routingRecords = {};

  @override
  void handle() {}

  @override
  void handleMessage(List<int> buffer, NetworkEntity src) {
    MessageHeader header = MessageHeader();

    header.build(buffer);
    if (src == this && header.destination == getIp()) {
      broadcastMessage(buffer, src, includeMessageRouter: false);
    } else if (header.destination == getIp()) {
      handleMessageInternally(buffer, src, header);
    } else if (header.destination == broadcastIP) {
      broadcastMessage(buffer, src);
    } else if (header.destination == localBroadcastIP) {
      localBroadcastMessage(buffer, src);
    } else {
      if (!containsRecord(header.destination)) {
        return;
      }
      var element = findRecord(header.destination);
      if (element != null) {
        if (element.destinationEntity == src) {
          broadcastMessage(buffer, src, includeMessageRouter: false);
          return;
        }
        element.destinationEntity.handleMessage(buffer, src);
      }
    }
  }

  @override
  void initialize() {
    routingRecords.clear();
    for (var i in NetworkManager.advertisedEntities) {
      routingRecords[i.ip] =
          MessageRouterRecord(destinationEntity: i, numberOfHops: 0);
    }
    for (var i in NetworkManager.backgroundDaemons) {
      routingRecords[i.ip] =
          MessageRouterRecord(destinationEntity: i, numberOfHops: 0);
    }
    super.initialize();
  }

  void send(List<int> buffer, NetworkEntity src, NetworkEntity dst) {
    if (src != dst) {
      dst.handleMessage(buffer, src);
    }
  }

  void sendLocal(
      MessageRouterRecord record, List<int> buffer, NetworkEntity src) {
    if (record.numberOfHops == 0) {
      send(buffer, src, record.destinationEntity);
    }
  }

  bool containsRecord(IP ip) {
    return findRecord(ip) != null;
  }

  MessageRouterRecord? findRecord(IP ip) {
    return routingRecords[ip];
  }

  bool foundBetterDestinationEntity(MessageRouterRecord newValue, IP ip) {
    return newValue.numberOfHops < (findRecord(ip)?.numberOfHops ?? ucharMax);
  }

  void broadcastMessage(List<int> buffer, NetworkEntity src,
      {bool includeMessageRouter = true}) {
    for (NetworkEntity entity in NetworkManager.switches) {
      send(buffer, src, entity);
    }
    localBroadcastMessage(
      buffer,
      src,
      includeMessageRouter: includeMessageRouter,
    );
  }

  void localBroadcastMessage(List<int> buffer, NetworkEntity src,
      {bool includeMessageRouter = true}) {
    for (NetworkEntity entity in NetworkManager.advertisedEntities) {
      send(buffer, src, entity);
    }
    for (NetworkEntity entity in NetworkManager.backgroundDaemons) {
      send(buffer, src, entity);
    }
    if (includeMessageRouter) {
      MessageHeader header = MessageHeader();
      header.build(buffer);
      handleMessageInternally(buffer, src, header);
    }
  }

  void handleMessageInternally(
      List<int> buffer, NetworkEntity src, MessageHeader header) {
    if (header.messageType ==
        MessageType(NetworkClock.messagePrimaryType,
            NetworkClockMessageTypes.syncNotification.index)) {
      handleSyncNotification(buffer, src, header);
    }
    if (header.messageType.mainType == messagePrimaryType) {
      if (header.messageType.secondaryType ==
          MessageRouterMessageTypes.updateMessage.index) {
        handleUpdateMessage(buffer, src, header);
      } else if (header.messageType.secondaryType ==
          MessageRouterMessageTypes.updateRequest.index) {
        handleUpdateRequestMessage(buffer, src, header);
      }
    }
  }

  createListFromAdvertisedRecords(
      Map<IP, MessageRouterRecord> advertisedRecords) {
    List out = [];
    advertisedRecords.forEach(
      (key, value) {
        if (value.numberOfHops == 0) {
          return;
        }
        out.add(
          MessageRouterRecordUpdate(
              ipOfDevice: key, numberOfHops: value.numberOfHops),
        );
      },
    );
    return out;
  }

  MessageRouter() : super(ip: messageRouterIp);
}
