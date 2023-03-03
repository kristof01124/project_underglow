import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'widgets/color_picker.dart';

var espId = "78:21:84:92:49:1E";

void main() {
  runApp(const MaterialApp(
    home: Scaffold(
      body: MyColorPicker(),
    ),
  ));
}
