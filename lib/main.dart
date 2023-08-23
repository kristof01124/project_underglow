import 'package:flutter/material.dart';

import 'package:learning_dart/GUI/views/main_view/main_view.dart';

var espMacAddress = "78:21:84:92:49:1E";

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: MainView(),
      ),
    ),
  );
}
