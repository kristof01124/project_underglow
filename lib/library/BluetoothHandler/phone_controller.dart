// This is the class, that creates a bridge between the backend and the frontend

import 'package:learning_dart/library/ArduinoNetwork/message.dart';
import 'package:learning_dart/library/ArduinoNetwork/serial.dart';
import 'package:learning_dart/library/ArduinoNetwork/switch.dart';
import 'package:learning_dart/library/ledcontroller/animation.dart';

class LedID {
  String macAddress;
  IP ip;

  LedID({required this.macAddress, required this.ip});
}

class LedcontrollerInfo {
  IP ip;

  LedcontrollerInfo({required this.ip});
}

class BoardInfo {
  Switch sw;
  List<LedcontrollerInfo> controllers = [];

  BoardInfo({required this.sw});
}

enum PhoneControllerMessageTypes { syncRequest, getDevices, getDevicesResponse }

class PhoneController {
  // This is the public api
  static List<LedID> getAvailableDevices() {
    throw UnimplementedError();
  }

  static void setAnimation({
    required LedID id,
    required ArduinAnimation animation,
    required int layer,
  }) {
    throw UnimplementedError();
  }

  static void synchronizeLeds({required List<LedID> ids, required int delay}) {
    throw UnimplementedError();
  }

  // This is the back part
  static const int messagePrimaryType = 101;

  static Map<String, BoardInfo> boards = {};

  static void addBoard(String id, Switch sw) {
    boards[id] = BoardInfo(sw: sw);
  }

  static Message createSyncRequest(
      {IP source = const IP(0, 0),
      IP destination = const IP(0, 0),
      List<IpMessageData> ips = const [],
      int delay = 0}) {
    return PairMessage(
      MessageHeader(
          source: source,
          destination: destination,
          messageType: MessageType(
            messagePrimaryType,
            PhoneControllerMessageTypes.syncRequest.index,
          )),
      PairMessage(
        MessageUint32(delay),
        ListMessage(
          (size) => List<IpMessageData>.filled(size, IpMessageData()),
          data: ips,
        ),
      ),
    );
  }
}
