import 'package:flutter/material.dart';

import '../library/ArduinoNetwork/message.dart';
import '../library/DeviceManager/device_manager.dart';
import 'animation_creator.dart';

abstract class AnimationCreatorWithDevices {
  AnimationCreatorWithDevices({required this.name, this.editing = false});

  Map<Device, Message> send();
  Widget build();

  final String name;
  bool editing;
}

class SimpleAnimationCreatorWithDevices extends AnimationCreatorWithDevices {
  final SimpleAnimationCreator animationCreator;
  final Device device;

  SimpleAnimationCreatorWithDevices({
    required this.device,
    required this.animationCreator,
    required super.name,
  });

  @override
  Widget build() {
    return animationCreator.build();
  }

  @override
  Map<Device, Message> send() {
    return {device: animationCreator.send()};
  }
}
