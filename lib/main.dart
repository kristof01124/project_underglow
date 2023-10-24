import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:learning_dart/library/ArduinoNetwork/Network_debugger.dart';
import 'package:learning_dart/library/ArduinoNetwork/global_value_store.dart';
import 'package:learning_dart/library/ArduinoNetwork/message.dart';
import 'package:learning_dart/library/ArduinoNetwork/message_router.dart';
import 'package:learning_dart/library/ArduinoNetwork/network_clock.dart';
import 'package:learning_dart/library/ArduinoNetwork/network_manager.dart';
import 'package:learning_dart/library/BluetoothHandler/bluetooth_handler.dart';

var espMacAddress = "78:21:84:92:49:1E";

void printMessageHeaderData(List<int> buffer) {
  MessageHeader header = MessageHeader();
  header.build(buffer);
  log("Digesting a message!\n"
      "source: ${header.source.primaryValue}.${header.source.secondaryValue}\n"
      "Destination: ${header.destination.primaryValue}.${header.destination.secondaryValue}\n"
      "Message type: ${header.messageType.primaryValue} ${header.messageType.secondaryValue}\n"
      "Checksum: ${header.checksum}\n"
      "Number of hops: ${header.numberOfHops}\n"
      "Size of payload: ${header.sizeOfPayload}"
      "----------------------------------------------------------------------");
}

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    NetworkManager.addEntity(
        NetworkClock(timeServer: false, delay: 5000, numberOfRepeats: 10));
    NetworkManager.addEntity(MessageRouter());
    NetworkManager.addEntity(BluetoothHandler(const Duration(seconds: 2)));
    NetworkManager.attachDebugger(
        NetworkDebugger(action: printMessageHeaderData));
    NetworkManager.initialize();
    return Container();
  }
}

void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: MainView(),
      ),
    ),
  );
}
