import 'package:flutter/material.dart';
import 'package:learning_dart/library/BluetoothHandler/bluetooth_handler.dart';

var espMacAddress = "78:21:84:92:49:1E";

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    var blehandler = BluetoothHandler(const Duration(seconds: 10));
    blehandler.initialize();

    return Container();
  }
}

void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: MainView(),
      ),
    ),
  );
}
