import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:learning_dart/library/ArduinoNetwork/Network_debugger.dart';
import 'package:learning_dart/library/ArduinoNetwork/advanced_debug_entity.dart';
import 'package:learning_dart/library/ArduinoNetwork/global_value_store.dart';
import 'package:learning_dart/library/ArduinoNetwork/message.dart';
import 'package:learning_dart/library/ArduinoNetwork/message_router.dart';
import 'package:learning_dart/library/ArduinoNetwork/network_clock.dart';
import 'package:learning_dart/library/ArduinoNetwork/network_manager.dart';
import 'package:learning_dart/library/BluetoothHandler/bluetooth_handler.dart';

var espMacAddress = "78:21:84:92:49:1E";

void foo() async {
  while (true) {
    AdvancedDebugEntity.printAllAvailableRoutes();
    AdvancedDebugEntity.printAllAvailableGVSValues();
    AdvancedDebugEntity.printSyncedTime();
    await Future.delayed(const Duration(seconds: 5));
  }
}

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    foo();

    NetworkManager.addEntity(
        NetworkClock(timeServer: false, delay: 5000, numberOfRepeats: 10));
    NetworkManager.addEntity(MessageRouter());
    NetworkManager.addEntity(BluetoothHandler(const Duration(seconds: 2)));
    NetworkManager.addEntity(GlobalValueStore(20));
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
