import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:learning_dart/library/ArduinoNetwork/serial.dart';

const serviceId = "a4c60af7-ef0b-44f5-a456-099136c6777d";
const writeCharacteristicId = "2908b78e-e7c4-4095-84b7-ad63ef4e922f";
const readCharacteristicId = "19f8b7ee-7721-4bcb-94b5-a40e059612e4";
const mtu = 250;

Duration waitDuration = const Duration(milliseconds: 1);

class BleSerial extends Serial {
  Iterable<int> writeCharacteristicValue = List.empty();
  String deviceId;

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
    handleReading();
    handleWriting();
  }

  void handleReading() async {
    while (true) {
      await Future.delayed(const Duration());
      readBuffer.addAll(
        await FlutterReactiveBle()
            .readCharacteristic(_readCharacteristic)
            .timeout(
              const Duration(seconds: 1),
              onTimeout: () => <int>[],
            ),
      );
      log(readBuffer.toString());
    }
  }

  void handleWriting() async {
    while (true) {
      await Future.delayed(const Duration());
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
