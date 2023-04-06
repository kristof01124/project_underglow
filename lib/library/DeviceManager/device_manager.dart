import 'package:flutter/material.dart';
import 'package:learning_dart/library/ArduinoNetwork/message_router.dart';
import 'package:learning_dart/views/detailed_led_view/detailed_led_view.dart';
import 'package:learning_dart/library/AnimationCreator/single_animation_creator.dart';

import '../ArduinoNetwork/message.dart';

/*
  THESE ARE HARDCODED CONSTANT PARTS, THIS MAKES THE MOST SENSE TO BE HERE, BUT SHOULD BE MOVED TO A CONFIG FILE LATER
*/
IP underglowIp = const IP(18);
IP leftIndexIP = const IP(17);

Device underglowDevice = Device(name: "Underglow", ip: underglowIp);

Map<IP, Device> _devices = {
  underglowIp: Device(
    ip: underglowIp,
    name: 'Underglow',
  ),
  leftIndexIP: Device(
    ip: leftIndexIP,
    name: 'Left index',
  ),
};
Map<IP, Widget> _listView = {};
Map<IP, Widget> _detailedView = {
  underglowIp: DetailedLedView(
    devices: [_devices[underglowIp] as Device],
  ),
  leftIndexIP: DetailedLedView(
    devices: [_devices[leftIndexIP] as Device],
  ),
};
Map<IP, LedDeviceState> _deviceData = {
  underglowIp: LedDeviceState(
    on: true,
    animationName: 'Fill',
    brightness: 200,
  ),
  leftIndexIP: LedDeviceState(
    on: false,
    animationName: 'Fill',
    brightness: 200,
  ),
};

class LedDeviceState {
  bool on;
  String animationName;
  SimpleAnimationCreator? currentlyPlayingAnimation;
  int brightness;

  LedDeviceState({
    required this.on,
    required this.animationName,
    this.currentlyPlayingAnimation,
    required this.brightness,
  });
}

/*
  This class is gonna connect the IP-s to leds, and their functionality
*/

// THis is a led device currently connected to the phone

class SendableAnimation {
  final String name;
  final SimpleAnimationCreator creator;

  SendableAnimation({required this.name, required this.creator});
}

class Device {
  final bool visible;
  final String name;
  final IP ip;
  Device({required this.name, required this.ip, this.visible = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Device &&
          runtimeType == other.runtimeType &&
          visible == other.visible &&
          name == other.name &&
          ip == other.ip;

  @override
  int get hashCode => visible.hashCode ^ name.hashCode ^ ip.hashCode;
}

// THis class is gonna handle the stuff that all the Devices will need
class DeviceManager {
  static List<Device> getDevices() {
    return _devices.values.toList();
    // ignore: dead_code
    List out = MessageRouter.advertisedRecords.keys.toList(growable: true);
    out.removeWhere((element) => !_devices.keys.toList().contains(element));
    return out.map((e) => (_devices[e] as Device)).toList();
  }

  static List<Device> getInteriorDevices() {
    List<Device> out = [];
    for (var device in getDevices()) {
      if (isInterior(device)) {
        out.add(device);
      }
    }
    return out;
  }

  static List<Device> getExteriorDevices() {
    List<Device> out = [];
    for (var device in getDevices()) {
      if (isExterior(device)) {
        out.add(device);
      }
    }
    return out;
  }

  static Widget getDetailedView(Device device) {
    return (_detailedView[device.ip] as Widget);
  }

  static Widget getListView(Device device) {
    return (_listView[device.ip] as Widget);
  }

  static LedDeviceState getData(Device device) {
    return (_deviceData[device.ip] as LedDeviceState);
  }

  static void setData(Device device, LedDeviceState data) {
    _deviceData[device.ip] = data;
  }

/*
  Interior leds should have an ip between 16 and 128
  Exterior leds should have an ip between 128 and 256
*/

  static bool isInterior(Device device) {
    return device.ip.entityIp < 128 && device.ip.entityIp > 16;
  }

  static bool isExterior(Device device) {
    return device.ip.entityIp >= 128 && device.ip.entityIp < 256;
  }
}
