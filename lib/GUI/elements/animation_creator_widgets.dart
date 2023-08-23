import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:learning_dart/library/AnimationCreator/single_animation_creator.dart';
import 'package:learning_dart/GUI/elements/stateful_slider.dart';
import 'my_color_picker.dart';

class AnimationCreatorWrapper extends StatefulWidget {
  final Widget child;
  final ValueWithDefault value;
  final String name;

  const AnimationCreatorWrapper({
    super.key,
    required this.child,
    required this.value,
    required this.name,
  });

  @override
  State<StatefulWidget> createState() {
    return _AnimationCreatorWrapperState();
  }
}

class _AnimationCreatorWrapperState extends State<AnimationCreatorWrapper> {
  @override
  Widget build(BuildContext context) {
    Widget body = widget.child;
    if (widget.value.editing) {
      body = Row(
        children: [
          Expanded(
            child: widget.child,
          ),
          Checkbox(
            value: widget.value.isDefault,
            onChanged: (checkboxValue) {
              if (checkboxValue != null) {
                setState(() {
                  widget.value.isDefault = checkboxValue;
                });
              }
            },
          ),
        ],
      );
    }
    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            '${widget.name}:',
            style: const TextStyle(
              fontSize: 30,
            ),
          ),
        ),
        body,
      ],
    );
  }
}

class AnimationCreatorInputField extends StatelessWidget {
  final ValueWithDefault<double> currentValue;
  final String name;

  const AnimationCreatorInputField({
    super.key,
    required this.currentValue,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    if (currentValue.isDefault) {
      return const SizedBox.shrink();
    }
    return AnimationCreatorWrapper(
        name: name,
        value: currentValue,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              // TODO: handle case when a non-number is inputted (in the ui)
              try {
                currentValue.value = double.parse(value);
              } catch (e) {
                log(e.toString());
              }
            },
          ),
        ));
  }
}

class AnimationCreatorSlider extends StatelessWidget {
  final double min, max;
  final ValueWithDefault<double> currentValue;
  final String name;

  const AnimationCreatorSlider({
    super.key,
    required this.min,
    required this.max,
    required this.currentValue,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    if (currentValue.isDefault) {
      return const SizedBox.shrink();
    }
    return AnimationCreatorWrapper(
      name: name,
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
  final String name;

  const AnimationCreatorColorWheel({
    super.key,
    required this.currentValue,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    if (currentValue.isDefault) {
      return const SizedBox.shrink();
    }
    return AnimationCreatorWrapper(
      name: name,
      value: currentValue,
      child: MyColorPicker(
        onColorChanged: (color) {
          currentValue.value = color;
        },
      ),
    );
  }
}
