import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:learning_dart/include/ArduinoNetwork/animation_message.dart';
import 'package:learning_dart/include/ArduinoNetwork/message.dart';
import 'package:learning_dart/widgets/stateful_slider.dart';

import 'color_picker.dart';

class ValueWithDefault<T> {
  T value;
  bool isDefault;
  bool editing;

  ValueWithDefault(this.value, {this.isDefault = false, this.editing = false});
}

class AnimationCreatorWrapper extends StatelessWidget {
  final Widget child;
  final ValueWithDefault value;

  const AnimationCreatorWrapper(
      {super.key, required this.child, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value.editing) {
      return child;
    }
    return Row(
      children: [
        Expanded(
          child: child,
        ),
        Checkbox(
          value: value.isDefault,
          onChanged: (checkboxValue) {
            if (checkboxValue != null) {
              value.isDefault = checkboxValue;
            }
          },
        ),
      ],
    );
  }
}

class AnimationCreatorSlider extends StatelessWidget {
  final double min, max;
  final ValueWithDefault<double> currentValue;

  const AnimationCreatorSlider({
    super.key,
    required this.min,
    required this.max,
    required this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    if (currentValue.isDefault) {
      return const SizedBox.shrink();
    }
    return AnimationCreatorWrapper(
      value: currentValue,
      child: StatefulSlider(
        value: currentValue.value,
        onChanged: (sliderValue) {
          currentValue.value = sliderValue;
        },
      ),
    );
  }
}

class AnimationCreatorColorWheel extends StatelessWidget {
  final ValueWithDefault<Color> currentValue;

  const AnimationCreatorColorWheel({
    super.key,
    required this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    if (currentValue.isDefault) {
      return const SizedBox.shrink();
    }
    return AnimationCreatorWrapper(
      value: currentValue,
      child: ColorPicker(
        enableAlpha: false,
        labelTypes: const [],
        pickerColor: currentValue.value,
        onColorChanged: (color) {
          currentValue.value = color;
        },
      ),
    );
  }
}

class AnimationCreatorApplyButton extends StatelessWidget {
  final AnimationCreator creator;

  const AnimationCreatorApplyButton(this.creator, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: creator.build(),
        ),
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

// This class is gonna be used for AnimationCreators, that are built up of primitives
abstract class SegmentAnimationCreator extends AnimationCreator {
  List<Widget> children = [];

  @override
  Widget build() {
    return Column(
      children: children,
    );
  }
}

class FillEffectCreator extends SegmentAnimationCreator {
  ValueWithDefault<double> duration = ValueWithDefault(0, isDefault: true);
  ValueWithDefault<Color> color = ValueWithDefault(Colors.black);

  FillEffectCreator({Function(AnimationCreator)? onButtonPressed}) {
    super.onButtonPressed = onButtonPressed;
    children.add(
      AnimationCreatorColorWheel(currentValue: color),
    );
  }

  @override
  Message send() {
    return FillEffectMessageBuilder(
      FillEffectMessage(
        duration.value.toInt(),
        color.value,
      ),
    );
  }
}
