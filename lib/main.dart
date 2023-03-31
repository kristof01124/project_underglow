import 'package:flutter/material.dart';
import 'package:learning_dart/library/AnimationCreator/animation_creator_with_device.dart';
import 'package:learning_dart/library/DeviceManager/device_manager.dart';

var espMacAddress = "78:21:84:92:49:1E";

void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: MainView(),
      ),
    ),
  );
}
