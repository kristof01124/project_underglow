import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:learning_dart/library/AnimationCreator/single_animation_creator.dart';

import '../DeviceManager/device_manager.dart';

class AnimationPicker {
  List<Device> devices;
  bool editing;
  SingleAnimationCreator? animation;

  void setDevices(List<Device> devices) {
    this.devices = devices;
  }

  AnimationPicker({
    required this.devices,
    this.editing = false,
  }) {
    log('We are here');
  }

  Widget build() {
    log('We are here');
    if (devices.isEmpty) {
      return Container(
        color: Colors.black,
        height: 200,
        width: 200,
      );
    }
    return Container(
      color: Colors.red,
      height: 200,
      width: 200,
    );
  }
}
