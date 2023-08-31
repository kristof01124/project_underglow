// ignore_for_file: prefer_initializing_formals

import 'package:learning_dart/library/ArduinoNetwork/message.dart';
import 'package:learning_dart/library/ArduinoNetwork/message_router.dart';
import 'package:learning_dart/library/ArduinoNetwork/network_manager.dart';

import 'network_entity.dart';

enum NetworkClockMessageTypes { syncRequest, syncResponse, syncNotification }

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

typedef NetworkClockSyncRequest = NetworkMessage<MessageUint64>;
typedef NetworkClockSynceResponse = NetworkMessage<SyncResponeBody>;
typedef NetworkClockSyncNotification = NetworkMessage<EmptyMessage>;

class NetworkClock extends NetworkEntity {
  static const int messagePrimaryType = 0;
  static const IP networkClockIp = IP(3);

  static NetworkClockSyncRequest createSyncRequest(
      {IP source = const IP(0), int time = 0}) {
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

  static NetworkClockSynceResponse createSyncResponse(
      {IP source = const IP(0),
      int time = 0,
      int timeDifference = 0,
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
        time,
        timeDifference,
        repeats,
      ),
    );
  }

  static NetworkClockSyncNotification createSyncNotification(
      {IP source = const IP(0)}) {
    return NetworkClockSyncNotification(
      MessageHeader(
        source: source,
        destination: MessageRouter
            .localBroadcastIP,
        messageType: MessageType(
          messagePrimaryType,
          NetworkClockMessageTypes.syncNotification.index,
        ),
      ),
      EmptyMessage(),
    );
  }

  void handleSyncRequest(
      List<int> buffer, NetworkEntity src, MessageHeader header) {
    if (!synced) {
      return;
    }
    NetworkClockSyncRequest request = createSyncRequest();
    request.build(buffer);
    int sentTime = request.second.value;
    src.handleMessage(
        createSyncResponse(
                source: networkClockIp,
                timeDifference: millis() - sentTime,
                time: sentTime)
            .buildBuffer(),
        this);
  }

  void handleSyncResponse(
      List<int> buffer, NetworkEntity src, MessageHeader header) {
    NetworkClockSynceResponse response = createSyncResponse();
    response.build(buffer);
    if (response.second.repeats % 2 == 0 ||
        response.second.repeats < syncRepeats) {
      src.handleMessage(
          createSyncResponse(
            source: networkClockIp,
            time: response.second.sourceTime,
            timeDifference: response.second.timeDifference,
            repeats: response.second.repeats,
          ).buildBuffer(),
          this);
      return;
    }
    double ping =
        (DateTime.now().millisecondsSinceEpoch - response.second.sourceTime) /
            (response.second.repeats + 1);
    timeDifference = response.second.timeDifference - ping;
    synced = true;
  }

  void handleSyncNotification(
      List<int> buffer, NetworkEntity src, MessageHeader header) {}

  static int lastUpdate = 0;
  static int delay = 0;

  static int timeDifference = 0;
  static bool synced = false;
  static bool timeServer = false;
  static int syncRepeats = 0;

  static bool isTimeServer() {
    return timeServer;
  }

  @override
  void handle() {
    if (!synced) {
      if (lastUpdate == 0 ||
          DateTime.now().millisecondsSinceEpoch - lastUpdate > delay) {
        NetworkManager.handleMessage(
            createSyncRequest(
                    source: networkClockIp,
                    time: DateTime.now().millisecondsSinceEpoch)
                .buildBuffer(),
            this);
        lastUpdate = DateTime.now().millisecondsSinceEpoch;
      }
    }
  }

  @override
  void handleMessage(List<int> buffer, NetworkEntity src) {
    MessageHeader header = MessageHeader();
    header.build(buffer);
    if (header.messageType.mainType != messagePrimaryType) {
      return;
    }
    int messageSecondaryType = header.messageType.secondaryType;
    if (messageSecondaryType == NetworkClockMessageTypes.syncRequest.index) {
      handleSyncRequest(buffer, src, header);
    } else if (messageSecondaryType ==
        NetworkClockMessageTypes.syncResponse.index) {
      handleSyncResponse(buffer, src, header);
    }
  }

  NetworkClock({bool timeServer = false, int delay = 0, int syncRepeats = 0})
      : super(ip: networkClockIp) {
    NetworkClock.timeServer = timeServer;
    NetworkClock.delay = delay;
    NetworkClock.syncRepeats = syncRepeats;
  }

  static int millis() {
    if (synced) {
      return DateTime.now().millisecondsSinceEpoch + timeDifference;
    }
    return 0;
  }
}
