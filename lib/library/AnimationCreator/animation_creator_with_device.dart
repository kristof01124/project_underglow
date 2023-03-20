import 'package:flutter/material.dart';
import 'package:learning_dart/library/AnimationCreator/animation_creator_animation_picker.dart';
import 'package:learning_dart/library/ArduinoNetwork/message.dart';
import 'package:learning_dart/library/DeviceManager/device_manager.dart';
import 'package:learning_dart/library/AnimationCreator/single_animation_creator.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

class AnimationCreatorWithDevices {
  AnimationCreatorWithDevices(
      {required this.name,
      this.editing = false,
      required this.availableDevices,
      List<Device> devices = const []})
      : animationPicker = AnimationPicker(devices: devices, editing: editing);

  List<Device> availableDevices;

  AnimationPicker animationPicker;

  Map<Device, Message> send() {
    Message? msg = animationPicker.animation?.send();
    if (msg == null) {
      return {};
    }
    Map<Device, Message> out = {};
    for (Device device in animationPicker.devices) {
      out[device] = msg;
    }
    return out;
  }

  Widget build() {
    return AnimationCreatorDevicePicker(
      availableDevices: availableDevices,
      animationPicker: animationPicker,
    );
  }

  final String name;
  bool editing;
}

class AnimationCreatorDevicePicker extends StatefulWidget {
  final List<Device> availableDevices;
  final AnimationPicker animationPicker;

  const AnimationCreatorDevicePicker({
    super.key,
    required this.availableDevices,
    required this.animationPicker,
  });

  @override
  State<AnimationCreatorDevicePicker> createState() =>
      _AnimationCreatorDevicePickerState();
}

class _AnimationCreatorDevicePickerState
    extends State<AnimationCreatorDevicePicker> {
  @override
  Widget build(BuildContext context) {
    if (!widget.animationPicker.editing) {
      return widget.animationPicker.build();
    }
    return Column(
      children: [
        MultiSelectDialogField(
          items: [
            for (Device device in widget.availableDevices)
              MultiSelectItem(
                device,
                device.name,
              ),
          ],
          onConfirm: (devices) {
            setState(() {
              widget.animationPicker.devices = devices;
            });
          },
        ),
        widget.animationPicker.build(),
      ],
    );
  }
}
