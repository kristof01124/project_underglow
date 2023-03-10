import 'package:flutter/material.dart';
import 'package:learning_dart/library/Network/message_router.dart';
import 'package:learning_dart/widgets/animation_creator.dart';

import '../ArduinoNetwork/message.dart';

/*
  THESE ARE HARDCODED CONSTANT PARTS, THIS MAKES THE MOST SENSE TO BE HERE, BUT SHOULD BE MOVED TO A CONFIG FILE LATER
*/
IP underglowIp = const IP(12);

Device underglowDevice = Device(name: "Underglow", ip: underglowIp);

Map<IP, Device> _devices = {};
Map<IP, Widget> _listView = {};
Map<IP, Widget> _detailedView = {};
Map<IP, Object> _deviceData = {};

class LedDeviceState {
  bool on;
  String animationName;
  Message? currentlyPlayingAnimation;
  int brightness;

  LedDeviceState(
    this.on,
    this.animationName,
    this.currentlyPlayingAnimation,
    this.brightness,
  );
}

/*
  This class is gonna connect the IP-s to leds, and their functionality
*/

// THis is a led device currently connected to the phone

class SendableAnimation {
  final String name;
  final AnimationCreator creator;

  SendableAnimation({required this.name, required this.creator});
}

class Device {
  final bool visible;
  final String name;
  final IP ip;
  Device({required this.name, required this.ip, this.visible = false});
}

// THis class is gonna handle the stuff that all the Devices will need
class DeviceManager {
  static List<Device> getDevices() {
    List out = MessageRouter.advertisedRecords.keys.toList(growable: true);
    out.removeWhere((element) => !_devices.keys.toList().contains(element));
    return out.map((e) => (_devices[e] as Device)).toList();
  }

  static Widget getDetailedView(Device device) {
    return (_detailedView[device.ip] as Widget);
  }

  static Widget getListView(Device device) {
    return (_listView[device.ip] as Widget);
  }

  static Object getData(Device device) {
    return (_deviceData[device.ip] as Object);
  }

  static Object setData(Device device, Object data) {
    return _deviceData[device.ip] = data;
  }
}

/*
  This class is gonna hold the available main animatins for a given Led.
*/
class MainAnimationManager {
  static List<SendableAnimation> getAnimationsForDevice(Device device) {
    // TODO
    return [];
  }
}
