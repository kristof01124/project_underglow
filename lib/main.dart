import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:learning_dart/widgets/animation_creator.dart';

var espId = "78:21:84:92:49:1E";

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: AnimationCreatorApplyButton(
          FillEffectCreator(
            onButtonPressed: (creator) {
              log(creator.send().buildBuffer().toString());
            },
          ),
        ),
      ),
    ),
  );
}
