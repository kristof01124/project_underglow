import 'dart:async';
import 'dart:collection';

import 'package:async/async.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:learning_dart/library/ArduinoNetwork/serial.dart';

const serviceId = "a4c60af7-ef0b-44f5-a456-099136c6777d";
const writeCharacteristicId = "19f8b7ee-7721-4bcb-94b5-a40e059612e4";
const readCharacteristicId = "2908b78e-e7c4-4095-84b7-ad63ef4e922f";
const mtu = 100;

Duration waitDuration = const Duration(milliseconds: 500);

class BleSerial extends Serial {
  Iterable<int> writeCharacteristicValue = List.empty();
  bool connected = false;
  String deviceId;
  CancelableOperation? operation;

  Queue<int> writeBuffer = Queue(), readBuffer = Queue();

  final QualifiedCharacteristic _readCharacteristic, _writeCharacteristic;

  BleSerial(this.deviceId)
      : _readCharacteristic = QualifiedCharacteristic(
          characteristicId: Uuid.parse(readCharacteristicId),
          serviceId: Uuid.parse(serviceId),
          deviceId: deviceId,
        ),
        _writeCharacteristic = QualifiedCharacteristic(
          characteristicId: Uuid.parse(writeCharacteristicId),
          serviceId: Uuid.parse(serviceId),
          deviceId: deviceId,
        ) {
    // Create background tasks
    handleReading();
    handleWriting();
  }

  Future<bool> canWrite() async {
    List<int> val =
        await FlutterReactiveBle().readCharacteristic(_writeCharacteristic);
    return val.isEmpty;
  }

  void handleReading() async {
    while (true) {
      readBuffer.addAll(
        await FlutterReactiveBle().readCharacteristic(_readCharacteristic),
      );
      await Future.delayed(waitDuration);
    }
  }

  void handleWriting() async {
    while (true) {
      // writing periodically
      if (writeBuffer.isEmpty) {
        await Future.delayed(waitDuration);
        continue;
      }
      if (!await canWrite()) {
        continue;
      }
      List<int> out = List.from(writeBuffer.take(mtu));
      await FlutterReactiveBle()
          .writeCharacteristicWithResponse(_writeCharacteristic, value: out);
      writeBuffer = Queue.from(writeBuffer.skip(out.length));
    }
  }

  @override
  int read() {
    return readBuffer.removeFirst();
  }

  @override
  int available() {
    return readBuffer.length;
  }

  @override
  void write(int value) {
    writeBuffer.add(value);
  }
}
