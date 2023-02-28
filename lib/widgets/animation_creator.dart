import 'dart:developer';

import 'package:analyzer_plugin/utilities/pair.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:learning_dart/include/ArduinoNetwork/animation_message.dart';
import 'package:learning_dart/include/ArduinoNetwork/message.dart';
import 'package:learning_dart/widgets/stateful_slider.dart';

/*  
  The idea of this widget is to connect the UI and the messageData part of the code
*/

/*
  TODO: implement a ColorPicker and Slider class, that has the following functionality:
    - Has a title by default
    - Has some basic parameters set by default
*/

class AnimationCreatorApplyButton extends StatelessWidget {
  final AnimationCreator creator;

  const AnimationCreatorApplyButton(this.creator, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        creator.build(),
        TextButton(
          onPressed: () {
            creator.onButtonPressed?.call(creator);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

abstract class AnimationCreator {
  /*
    TODO: Get json representation
    Requirement: json handler implementation
  */
  Widget build();
  Message send();

  Function(AnimationCreator)? onButtonPressed;

  AnimationCreator({this.onButtonPressed});
}

class FillEffectCreator extends AnimationCreator {
  int? duration;
  Color? color;
  FillEffectCreator({this.duration, this.color, super.onButtonPressed});

  @override
  Widget build() {
    List<Widget> children = [];
    if (duration == null) {
      duration = 0;
      children.add(
        StatefulSlider(
          value: (duration as int).toDouble(),
          onChanged: (value) {
            duration = value.toInt();
          },
        ),
      );
    }
    if (color == null) {
      color = const Color.fromARGB(255, 0, 0, 0);
      children.add(
        ColorPicker(
          enableAlpha: false,
          labelTypes: const [],
          pickerColor: (color as Color),
          onColorChanged: (value) {
            color = value;
          },
        ),
      );
    }
    return Column(
      children: children,
    );
  }

  @override
  Message send() {
    if (duration == null || color == null) {
      throw Exception(
          'Tried to create message data to not fully initialized message.');
    }
    return FillEffectMessageBuilder(
      FillEffectMessage(
        (duration as int),
        RGB.fromColor(color as Color),
      ),
    );
  }
}
