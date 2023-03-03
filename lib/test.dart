import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Color Picker Example'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              // show color picker dialog
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Pick a color'),
                    content: SingleChildScrollView(
                      child: BlockPicker(
                        pickerColor: Colors.blue,
                        onColorChanged: (color) {
                          // handle color changes
                          print(color);
                        },
                        // optional parameters
                      ),
                    ),
                  );
                },
              );
            },
            child: Text('Show Color Picker'),
          ),
        ),
      ),
    );
  }
}
