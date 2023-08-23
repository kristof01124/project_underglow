import 'package:flutter/material.dart';
import 'package:learning_dart/library/ArduinoNetwork/animation_message.dart';
import 'package:learning_dart/library/ArduinoNetwork/message.dart';
import 'package:learning_dart/GUI/elements/animation_creator_widgets.dart';
import 'package:learning_dart/library/AnimationCreator/single_animation_creator.dart';

class FillEffectCreator extends SegmentAnimationCreator {
  FillEffectCreator({
    super.editing,
    Function(SimpleAnimationCreator creator)? onButtonPressed,
    double? duration,
    Color? color,
  }) : super(
          name: 'Fill',
        ) {
    children = [
      AnimationCreatorInputField(
        currentValue: ValueWithDefault(
          duration ?? 0.0,
          isDefault: duration != null,
          editing: editing,
        ),
        name: 'Duration',
      ),
      AnimationCreatorColorWheel(
        currentValue: ValueWithDefault(
          color ?? Colors.black,
          isDefault: color != null,
          editing: editing,
        ),
        name: 'Color',
      ),
    ];
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
