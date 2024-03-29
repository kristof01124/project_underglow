import 'dart:developer';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:learning_dart/library/ArduinoNetwork/message.dart';
import 'package:learning_dart/library/ArduinoNetwork/network_entity.dart';
import 'package:learning_dart/library/BluetoothHandler/ble_serial.dart';
import 'package:learning_dart/library/ArduinoNetwork/switch.dart';
import 'package:learning_dart/library/BluetoothHandler/phone_controller.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothHandler extends NetworkEntity {
  Duration scanDuration;

  final availableDevices = {};

  List<Switch> bleSwitches = [];

  connect(DiscoveredDevice device) {
    FlutterReactiveBle()
        .connectToDevice(
      id: device.id,
    )
        .listen(
      (ConnectionStateUpdate event) async {
        if (event.connectionState == DeviceConnectionState.connected) {
          if (availableDevices.containsKey(device.id)) {
            return;
          }
          availableDevices[device.id] = device;
          await FlutterReactiveBle().discoverServices(event.deviceId);
          PhoneController.addBoard(
            device.id,
            Switch(
              BleSerial(
                device.id,
              ),
            ),
          );
        }
      },
    );
  }

  BluetoothHandler(this.scanDuration);

  @override
  void initialize() async {
    await Permission.locationWhenInUse.request();
    FlutterReactiveBle().scanForDevices(
      withServices: [Uuid.parse(serviceId)],
      scanMode: ScanMode.lowLatency,
    ).listen(
      (device) {
        connect(device);
      },
    );
  }

  @override
  void handleMessage(List<int> buffer, NetworkEntity src) {}
}
