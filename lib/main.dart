import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:learning_dart/library/AnimationCreator/animation_creator_with_device.dart';
import 'package:learning_dart/library/DeviceManager/device_manager.dart';
import 'package:learning_dart/library/Network/ledcontroller_messages.dart';

import 'library/ArduinoNetwork/message.dart';

var espMacAddress = "78:21:84:92:49:1E";

void main() {
  log("nice");
  log(MessageHeader().buildBuffer().toString());
  log(SetBrigthnessMessage(
    destination: const IP(3),
    brightness: 60,
  ).buildBuffer().toString());
  /*
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: MainView(),
      ),
    ),
  );ű
  */
}
