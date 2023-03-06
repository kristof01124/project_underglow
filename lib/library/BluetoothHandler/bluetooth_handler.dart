/*
  This class is gonna be responsible for finding possible ble serials, creating and storing them, 
  and closing them if the connection is broken.
*/

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:learning_dart/library/BluetoothHandler/ble_serial.dart';
import 'package:learning_dart/library/ArduinoNetwork/switch.dart';

class BluetoothHandler {
  static Duration scanDuration = const Duration(seconds: 2);

  static final availableDevices = {};

  static Switch? bleSwitch;

  static connect(DiscoveredDevice device) {
    FlutterReactiveBle()
        .connectToDevice(
      id: device.id,
      connectionTimeout: const Duration(seconds: 1),
    )
        .listen(
      (event) async {
        if (event.failure == null) {
          bleSwitch = Switch(BleSerial(device.id));
        }
      },
    );
  }

  static void initialize() {
    FlutterReactiveBle().scanForDevices(
      withServices: [Uuid.parse(serviceId)],
      scanMode: ScanMode.lowLatency,
    ).listen(
      (device) {
        availableDevices[device.id] = device;
      },
    );
  }
}
