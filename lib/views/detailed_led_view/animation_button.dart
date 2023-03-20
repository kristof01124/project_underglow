import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:learning_dart/library/AnimationCreator/single_animation_creator.dart';

class AnimationButton extends StatefulWidget {
  final SingleAnimationCreator animationCreator;

  const AnimationButton({super.key, required this.animationCreator});

  @override
  State<AnimationButton> createState() => _AnimationButtonState();
}

class _AnimationButtonState extends State<AnimationButton> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.animationCreator.name);
  }
}
