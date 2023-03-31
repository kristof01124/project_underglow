import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:learning_dart/library/AnimationCreator/animation_creator_implementations.dart';
import 'package:learning_dart/library/AnimationCreator/single_animation_creator.dart';

import '../../widgets/stateful_dropdown_button.dart';
import '../DeviceManager/device_manager.dart';

class AnimationPicker {
  List<Device> devices;
  bool editing;
  SimpleAnimationCreator? animation;
  final List<SimpleAnimationCreator> animations;

  void setDevices(List<Device> devices) {
    this.devices = devices;
  }

  AnimationPicker({
    required this.animations,
    required this.devices,
    this.editing = false,
  });

  Widget build() {
    return AnimationPickerWidget(animationPicker: this);
  }
}

class AnimationPickerWidget extends StatefulWidget {
  final AnimationPicker animationPicker;
  const AnimationPickerWidget({super.key, required this.animationPicker});

  @override
  State<AnimationPickerWidget> createState() => _AnimationPickerWidgetState();
}

class _AnimationPickerWidgetState extends State<AnimationPickerWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton(
              value: widget.animationPicker.animation,
              onChanged: (value) {
                setState(
                  () {
                    widget.animationPicker.animation = value;
                  },
                );
              },
              items: [
                for (SimpleAnimationCreator animation
                    in widget.animationPicker.animations)
                  DropdownMenuItem(
                      value: animation, child: Text(animation.name))
              ],
            ),
          ),
        ),
        widget.animationPicker.animation?.build() ?? Container(),
      ],
    );
  }
}
