import 'package:flutter/material.dart';
import 'package:learning_dart/views/preset_creator_view/preset_creator_view.dart';

var espMacAddress = "78:21:84:92:49:1E";

void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: PresetCreatorView(),
      ),
    ),
  );
}
