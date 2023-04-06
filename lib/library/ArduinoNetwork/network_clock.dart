import 'package:learning_dart/library/ArduinoNetwork/message.dart';
import 'package:learning_dart/library/ArduinoNetwork/network_manager.dart';

import 'network_entity.dart';

enum NetworkClockMessageTypes {
  syncRequest,
  syncResponse,
}

class NetworkClock extends NetworkEntity {
  static Duration delayWhenSynced = const Duration(milliseconds: 100),
      delayWhenNotSynced = const Duration(milliseconds: 100);

  static const IP networkClockIp = IP(3);
  static const int messagePrimaryType = 3;

  static int lastUpdate = DateTime.now().millisecondsSinceEpoch;
  static int timeDifference = 0;
  static bool isSynced = false;

  // Can't be timeserver, so no need for timeserver parameter

  static Set<int> sentRequestTimes = {};

  Duration delay() {
    if (isSynced) {
      return delayWhenSynced;
    }
    return delayWhenNotSynced;
  }

  @override
  void handle() {
    if (DateTime.now().millisecondsSinceEpoch - lastUpdate >
        delay().inMilliseconds) {
      sendSyncRequest();
    }
  }

  void handleSyncRequest(NetworkClockSyncRequest request) {
    if (!isSynced) {
      return;
    }
    NetworkManager.handleMessage(
      NetworkClockSyncResponse(
        sentTime: request.first.time,
      ).buildBuffer(),
      this,
    );
  }

  void handleSyncResponse(NetworkClockSyncResponse response) {
    int sentTime = response.sentTime;
    if (!sentRequestTimes.contains(sentTime)) {
      return;
    }
    sentRequestTimes.remove(sentTime);
    double delta = (DateTime.now().millisecondsSinceEpoch - sentTime) / 2;
    int officialTime = response.first.time + delta.toInt();
    timeDifference = officialTime - DateTime.now().millisecondsSinceEpoch;
  }

  @override
  void handleMessage(List<int> buffer, NetworkEntity src) {
    MessageHeader header = MessageHeader();
    header.build(buffer);
    if (header.messageType.mainType != messagePrimaryType) {
      return;
    }
    int type = header.messageType.secondaryType;
    if (type == NetworkClockMessageTypes.syncRequest.index) {
      NetworkClockSyncRequest request = NetworkClockSyncRequest();
      request.build(buffer);
      handleSyncRequest(request);
    } else if (type == NetworkClockMessageTypes.syncResponse.index) {
      NetworkClockSyncResponse response = NetworkClockSyncResponse();
      response.build(buffer);
      handleSyncResponse(response);
    }
  }

  static int millis() {
    if (!isSynced) {
      return 0;
    } else {
      return DateTime.now().millisecondsSinceEpoch + timeDifference;
    }
  }

  void sendSyncRequest() {
    int time = DateTime.now().millisecondsSinceEpoch;
    sentRequestTimes.add(time);
    NetworkManager.handleMessage(
      NetworkClockSyncRequest(time: time).buildBuffer(),
      this,
    );
  }
}

class NetworkClockSyncRequest extends NetworkMessage {
  NetworkClockSyncRequest({int time = 0})
      : super(
          MessageHeader(
            destination: NetworkClock.networkClockIp,
            messageType: MessageType(
              NetworkClock.messagePrimaryType,
              NetworkClockMessageTypes.syncRequest.index,
            ),
            time: time,
          ),
          EmptyMessage(),
        );
}

class NetworkClockSyncResponse extends NetworkMessage {
  NetworkClockSyncResponse({int sentTime = 0})
      : super(
          MessageHeader(
            destination: NetworkClock.networkClockIp,
            messageType: MessageType(
              NetworkClock.messagePrimaryType,
              NetworkClockMessageTypes.syncRequest.index,
            ),
          ),
          MessageUint64(
            sentTime,
          ),
        );
  int get sentTime => (second as MessageUint64).value;
}
