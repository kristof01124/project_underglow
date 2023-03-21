

import 'package:flutter/material.dart';
import 'package:learning_dart/library/ArduinoNetwork/animation_message.dart';
import 'package:learning_dart/library/ArduinoNetwork/message.dart';
import 'package:learning_dart/widgets/animation_creator_widgets.dart';
import 'package:learning_dart/library/AnimationCreator/single_animation_creator.dart';

class FillEffectCreator extends SegmentAnimationCreator {
  FillEffectCreator({
    super.editing,
    Function(SingleAnimationCreator creator)? onButtonPressed,
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