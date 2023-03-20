import 'package:flutter/material.dart';
import 'package:learning_dart/library/ArduinoNetwork/message.dart';

class ValueWithDefault<T> {
  T value;
  bool isDefault;
  bool editing;

  ValueWithDefault(this.value, {this.isDefault = false, this.editing = false});
}

abstract class SingleAnimationCreator {
  /*
    TODO: Get json representation
    Requirement: json handler implementation
  */
  bool editing;

  Widget build();
  Message send();
  String name;

  SingleAnimationCreator({
    required this.name,
    this.editing = false,
  });
}

// This class is gonna be used for AnimationCreators, that are built up of primitives
abstract class SegmentAnimationCreator extends SingleAnimationCreator {
  List<Widget> children = [];

  SegmentAnimationCreator({
    this.children = const [],
    required super.name,
    super.editing,
  });

  @override
  Widget build() {
    return Column(
      children: children,
    );
  }
}
