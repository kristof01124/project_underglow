import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:learning_dart/library/ArduinoNetwork/animation_message.dart';
import 'package:learning_dart/library/ArduinoNetwork/message.dart';
import 'package:learning_dart/widgets/stateful_slider.dart';

import 'my_color_picker.dart';

class ValueWithDefault<T> {
  T value;
  bool isDefault;
  bool editing;

  ValueWithDefault(this.value, {this.isDefault = false, this.editing = false});
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
              // TODO: handle case when a non-number is inputted
              currentValue.value = double.parse(value);
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

class AnimationCreatorApplyButton extends StatelessWidget {
  final SimpleAnimationCreator? creator;

  const AnimationCreatorApplyButton({
    this.creator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (this.creator == null) {
      return Container();
    }
    SimpleAnimationCreator creator = (this.creator as SimpleAnimationCreator);
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

/*
  This class is gonna be used for simple animations, without a device connected.
*/
abstract class SimpleAnimationCreator {
  /*
    TODO: Get json representation
    Requirement: json handler implementation
  */
  bool editing;

  Widget build();
  Message send();
  String name;

  Function(SimpleAnimationCreator)? onButtonPressed;

  SimpleAnimationCreator({
    this.onButtonPressed,
    required this.name,
    this.editing = false,
  });
}

// This class is gonna be used for AnimationCreators, that are built up of primitives
abstract class SegmentAnimationCreator extends SimpleAnimationCreator {
  List<Widget> children = [];

  SegmentAnimationCreator(
      {this.children = const [],
      required super.name,
      super.editing,});

  @override
  Widget build() {
    return Column(
      children: children,
    );
  }
}

class FillEffectCreator extends SegmentAnimationCreator {
  FillEffectCreator({
    super.editing,
    Function(SimpleAnimationCreator creator)? onButtonPressed,
  }) : super(
          name: 'Fill',
        ) {
    children = [
      AnimationCreatorInputField(
        currentValue: ValueWithDefault(
          0,
          editing: editing,
          isDefault: !editing,
        ),
        name: 'Duration',
      ),
      AnimationCreatorColorWheel(
        currentValue: ValueWithDefault(
          Colors.black,
          editing: editing,
        ),
        name: 'Color',
      ),
    ];
    super.onButtonPressed = onButtonPressed;
  }

  @override
  Message send() {
    return FillEffectMessageBuilder(
      FillEffectMessage(
        (children[0] as AnimationCreatorInputField).currentValue.value.toInt(),
        (children[1] as AnimationCreatorColorWheel).currentValue.value,
      ),
    );
  }
}
