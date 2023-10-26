// ignore_for_file: prefer_initializing_formals

import 'dart:developer';

import 'package:learning_dart/library/ArduinoNetwork/message.dart';
import 'package:learning_dart/library/ArduinoNetwork/network_manager.dart';

import 'network_entity.dart';

class SyncResponeBody extends SegmentMessage {
  SyncResponeBody(int sourceTime, int timeDifference, int repeats) {
    add('sourceTime', MessageUint64(sourceTime));
    add('timeDifference', MessageInt64(timeDifference));
    add('repeats', MessageUint8(repeats));
  }

  get sourceTime => (segments['sourceTime'] as MessageUint64).value;
  get timeDifference => (segments['timeDifference'] as MessageInt64).value;
  get repeats => (segments['repeats'] as MessageUint8).value;
}

enum NetworkClockMessageTypes { syncRequest, syncResponse, syncNotification }

typedef NetworkClockSyncRequest = NetworkMessage<MessageUint64>;
typedef NetworkClockSynceResponse = NetworkMessage<SyncResponeBody>;
typedef NetworkClockSyncNotification = NetworkMessage<EmptyMessage>;

class NetworkClock extends NetworkEntity {
  static const int messagePrimaryType = 2;

  static NetworkClockSyncRequest createSyncRequest(
      {IP source = const IP(0, 0), int time = 0}) {
    return NetworkClockSyncRequest(
      MessageHeader(
        source: source,
        destination: source,
        messageType: MessageType(
          messagePrimaryType,
          NetworkClockMessageTypes.syncRequest.index,
        ),
      ),
      MessageUint64(time),
    );
  }

  static NetworkClockSynceResponse createSyncResponseMessage(
      {IP source = const IP(0, 0),
      int timeDifference = 0,
      int requestTime = 0,
      int repeats = 0}) {
    return NetworkClockSynceResponse(
      MessageHeader(
        source: source,
        destination: source,
        messageType: MessageType(
          messagePrimaryType,
          NetworkClockMessageTypes.syncResponse.index,
        ),
      ),
      SyncResponeBody(
        requestTime,
        timeDifference,
        repeats,
      ),
    );
  }

  static NetworkClockSyncNotification createSyncNotification(
      {IP source = const IP(0, 0)}) {
    return NetworkClockSyncNotification(
      MessageHeader(
        source: source,
        destination: NetworkManager.localBroadcastIP,
        messageType: MessageType(
          messagePrimaryType,
          NetworkClockMessageTypes.syncNotification.index,
        ),
      ),
      EmptyMessage(),
    );
  }

  static int lastUpdate = 0;
  static int syncRequestDelay = 0;

  static int timeDifference = 0;
  static bool synced = false;
  static bool timeServer = false;
  static int numberOfRepeats = 0;

  @override
  void handleMessage(List<int> buffer, NetworkEntity src) {
    MessageHeader header = MessageHeader();
    header.build(buffer);
    if (header.messageType ==
        MessageType(
          messagePrimaryType,
          NetworkClockMessageTypes.syncRequest.index,
        )) {
      handleSyncRequest(buffer, src, header);
    } else if (header.messageType ==
        MessageType(
          messagePrimaryType,
          NetworkClockMessageTypes.syncResponse.index,
        )) {
      handleSyncResponse(buffer, src, header);
    }
  }

  @override
  void handle() {
    if (!synced) {
      if (lastUpdate == 0 ||
          DateTime.now().millisecondsSinceEpoch - lastUpdate >
              syncRequestDelay) {
        NetworkManager.handleMessage(
            createSyncRequest(
              source: getIp(),
              time: DateTime.now().millisecondsSinceEpoch,
            ).buildBuffer(),
            this);
        lastUpdate = DateTime.now().millisecondsSinceEpoch;
      }
    }
  }

  @override
  IP getIp() {
    return const IP(0, 2);
  }

  void handleSyncRequest(
      List<int> buffer, NetworkEntity src, MessageHeader header) {
    if (!synced) {
      return;
    }
    NetworkClockSyncRequest request = createSyncRequest();
    request.build(buffer);
    int sentTime = request.second.value;
    NetworkManager.sendMessage(
        createSyncResponseMessage(
          source: getIp(),
          timeDifference: DateTime.now().millisecondsSinceEpoch - sentTime,
          requestTime: sentTime,
          repeats: 2,
        ).buildBuffer(),
        this,
        src);
  }

  void handleSyncResponse(
      List<int> buffer, NetworkEntity src, MessageHeader header) {
    NetworkClockSynceResponse response = createSyncResponseMessage();
    response.build(buffer);
    if ((response.second.repeats % 2 == 1 ||
            response.second.repeats < numberOfRepeats) &&
        (!synced || isTimeServer())) {
      NetworkManager.sendMessage(
          createSyncResponseMessage(
            source: getIp(),
            requestTime: response.second.sourceTime,
            timeDifference: response.second.timeDifference,
            repeats: response.second.repeats + 1,
          ).buildBuffer(),
          this,
          src);
      return;
    }
    if (synced) {
      return;
    }
    double ping =
        (DateTime.now().millisecondsSinceEpoch - response.second.sourceTime) /
            response.second.repeats;
    timeDifference = response.second.timeDifference - ping.round();
    if (!synced) {
      NetworkManager.handleMessage(
          createSyncNotification(
            source: getIp(),
          ).buildBuffer(),
          this);
    }
    synced = true;
  }

  NetworkClock(
      {required timeServer, required int delay, required int numberOfRepeats}) {
    NetworkClock.timeServer = timeServer;
    NetworkClock.synced = timeServer;
    NetworkClock.syncRequestDelay = delay;
    NetworkClock.numberOfRepeats = numberOfRepeats;
  }

  static bool isTimeServer() {
    return timeServer;
  }

  static int millis() =>
      synced ? DateTime.now().millisecondsSinceEpoch + timeDifference : 0;

  static int convertLocalToServer(int time) => time - timeDifference;
}
