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

class AnimationCreatorDevicePicker extends SimpleAnimationCreator {
  final ValueWithDefault<Set<Device>> devices;
  final List<Device> avialableDevices;

  AnimationCreatorDevicePicker({
    required this.devices,
    required this.avialableDevices,
    required super.name,
    super.editing,
  });

  @override
  Widget build() {
    return DropdownButton<AnimationCreatorDevicePickerButton>(
      items: [
        for (Device device in avialableDevices)
          DropdownMenuItem(
            child: AnimationCreatorDevicePickerButton(
                device: device, devices: devices),
          )
      ],
      onChanged: (Object? value) {},
    );
  }

  @override
  Message send() {
    return EmptyMessage();
  }
}

class AnimationCreatorDevicePickerButton extends StatefulWidget {
  final Device device;
  final ValueWithDefault<Set<Device>> devices;

  const AnimationCreatorDevicePickerButton(
      {super.key, required this.device, required this.devices});

  @override
  State<AnimationCreatorDevicePickerButton> createState() =>
      _AnimationCreatorDevicePickerButtonState();
}

class _AnimationCreatorDevicePickerButtonState
    extends State<AnimationCreatorDevicePickerButton> {
  bool value = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget.device.name),
        Checkbox(
            value: value,
            onChanged: (value) {
              this.value = value ?? false;
              if (this.value) {
                widget.devices.value.add(widget.device);
              } else {
                widget.devices.value.remove(widget.device);
              }
            })
      ],
    );
  }
}

class SimpleAnimationCreatorWithDevices extends AnimationCreatorWithDevices {
  final SimpleAnimationCreator animationCreator;
  final List<Device> devices;

  SimpleAnimationCreatorWithDevices({
    required this.devices,
    required this.animationCreator,
    required super.name,
  });

  @override
  Widget build() {
    return animationCreator.build();
  }

  @override
  Map<Device, Message> send() {
    return {
      for (Device device in devices) device: animationCreator.send(),
    };
  }
}
