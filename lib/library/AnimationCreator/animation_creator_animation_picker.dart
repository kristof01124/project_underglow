import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:learning_dart/library/AnimationCreator/animation_creator_implementations.dart';
import 'package:learning_dart/library/AnimationCreator/single_animation_creator.dart';

import '../DeviceManager/device_manager.dart';

class AnimationPicker {
  List<Device> devices;
  bool editing;
  SingleAnimationCreator? animation;
  final List<SingleAnimationCreator> Function() getAnimations;

  void setDevices(List<Device> devices) {
    this.devices = devices;
  }

  AnimationPicker({
    required this.getAnimations,
    required this.devices,
    this.editing = false,
  });

  Widget build() {
    if (animation != null) {
      return animation?.build() ?? Container();
    }

    return DropdownButton(
      onChanged: ,
      items: [
      for (SingleAnimationCreator animation in getAnimations())
        DropdownMenuItem(value: animation.name, child: Text(animation.name))
    ]);
  }
}
