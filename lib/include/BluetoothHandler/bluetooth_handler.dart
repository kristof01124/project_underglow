/*
  This class is gonna be responsible for finding possible ble serials, creating and storing them, 
  and closing them if the connection is broken.
*/

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:learning_dart/include/BluetoothHandler/ble_serial.dart';
import 'package:learning_dart/include/ArduinoNetwork/switch.dart';

class BluetoothHandler {
  static Duration scanDuration = const Duration(seconds: 2);

  static Map<String, Switch> switches = {};

  static String? pairedDevice;

  static void initialize() {
    FlutterReactiveBle().scanForDevices(
        withServices: [Uuid.parse(serviceId)],
        scanMode: ScanMode.lowLatency).listen((device) {
      if (pairedDevice != null && device.name != pairedDevice) {
        return;
      }
      FlutterReactiveBle()
          .connectToDevice(
        id: device.id,
        connectionTimeout: const Duration(seconds: 1),
      )
          .listen(
        (event) async {
          if (event.failure == null) {
            pairedDevice = device.name;
            if (switches.containsKey(device.id)) {
              return;
            }
            switches[device.id] = Switch(BleSerial(device.id));
          }
        },
      );
    });
  }
}
