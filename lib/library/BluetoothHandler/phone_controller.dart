// This is the class, that creates a bridge between the backend and the frontend

import 'package:learning_dart/library/ArduinoNetwork/message.dart';
import 'package:learning_dart/library/ArduinoNetwork/switch.dart';
import 'package:learning_dart/library/BluetoothHandler/ble_serial.dart';
import 'package:learning_dart/library/ledcontroller/animation.dart';
import 'package:learning_dart/library/ledcontroller/led_controller_messages.dart';

class LedID {
  String macAddress;
  IP ip;

  LedID({required this.macAddress, required this.ip});

  @override
  int get hashCode => (macAddress.hashCode.toString() + ip.hashCode.toString()).hashCode;
  
  @override
  bool operator ==(Object other) {
    return super.hashCode == other.hashCode;
  }
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

class GetDevicesResponseMessage extends SegmentMessage {
  GetDevicesResponseMessage(
      {required MessageHeader header, ListMessage? data}) {
    data ??= ListMessage((size) => List.filled(size, IpMessageData()));
    add("header", header);
    add("data", data);
  }

  MessageHeader get header => (segments["header"] as MessageHeader);
  List<IP> get data =>
      ((segments["data"] as ListMessage).data as List<IpMessageData>)
          .map(
            (e) => e.value,
          )
          .toList();
}

typedef GetDevicesMessage = MessageHeader;

class PhoneController {
  static const IP phoneControllerIP = IP(20, 2);
  static const IP arduinoPhoneControllerIP = IP(20, 1);

  // This is the public api
  static List<LedID> getAvailableLeds() {
    return leds.toList();
  }

  static List<String> getAvailableBoards() {
    return boards.keys.toList();
  }

  static void setAnimation({
    required LedID id,
    required ArduinoAnimation animation,
    required int layer,
  }) {
    Switch? sw = boards[id]?.sw;
    if (sw == null) {
      return;
    }
    sw.handleMessage(
        LedController.crateSetAnimationMessage(
                source: PhoneController.phoneControllerIP,
                destination: id.ip,
                index: layer,
                animation: animation)
            .buildBuffer(),
        sw);
  }

  static void synchronizeLeds({required List<LedID> ids, required int delay}) {
    for (var id in ids) {
      Switch? sw = boards[id]?.sw;
      if (sw == null) {
        continue;
      }
      sw.handleMessage(
          LedController.createSyncMessage(
                  source: PhoneController.phoneControllerIP,
                  destination: id.ip,
                  time: delay)
              .buildBuffer(),
          sw);
    }
  }

  // This is the back part
  static const int messagePrimaryType = 101;

  static Map<String, BoardInfo> boards = {};
  static Set<LedID> leds = {};

  static void handleMessage(List<int> buffer, Switch sw) {
    var header = MessageHeader();
    header.build(buffer);
    if (header.messageType ==
        MessageType(messagePrimaryType,
            PhoneControllerMessageTypes.getDevicesResponse.index)) {
      var msg = GetDevicesResponseMessage(header: MessageHeader());
      msg.build(buffer);
      for (var entry in msg.data) {
        leds.add(LedID(macAddress: getIdBySwitch(sw), ip: entry));
      }
    }
  }

  static String getIdBySwitch(Switch sw) {
    for (var entry in boards.entries) {
      if (entry.value.sw == sw) {
        return entry.key;
      }
    }
    return "";
  }

  static void addBoard(String id, Switch sw) {
    boards[id] = BoardInfo(sw: sw);
    dicoverLeds();
  }

  static GetDevicesMessage createGetDevicesMessage(
      {required IP source, required IP destination}) {
    return GetDevicesMessage(
      source: source,
      destination: destination,
      messageType: MessageType(
        messagePrimaryType,
        PhoneControllerMessageTypes.getDevices.index,
      ),
    );
  }

  static GetDevicesResponseMessage createGetDevicesResponseMessage(
      {required IP source, required IP destination, ListMessage? data}) {
    return GetDevicesResponseMessage(
      header: MessageHeader(
          source: source,
          destination: destination,
          messageType: MessageType(
            messagePrimaryType,
            PhoneControllerMessageTypes.getDevicesResponse.index,
          )),
      data: data,
    );
  }

  static void dicoverLeds() {
    for (var board in boards.values) {
      var sw = board.sw;
      sw.handleMessage(
        createGetDevicesMessage(
                source: phoneControllerIP,
                destination: arduinoPhoneControllerIP)
            .buildBuffer(),
        sw,
      );
    }
  }
}
