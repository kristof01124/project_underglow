import 'package:flutter/material.dart';
import 'package:learning_dart/include/ArduinoNetwork/message.dart';
import 'package:learning_dart/widgets/stateful_slider.dart';

class ValueWithDefault<T> {
  T value;
  bool isDefault = false;

  ValueWithDefault(this.value);
}

class AnimationCreatorWrapper extends StatelessWidget {
  final Widget child;
  final ValueWithDefault value;

  const AnimationCreatorWrapper(
      {super.key, required this.child, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        child,
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

class FillEffectCreator extends AnimationCreator {}
