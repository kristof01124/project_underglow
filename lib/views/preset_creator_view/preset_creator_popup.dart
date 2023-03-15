import 'dart:developer';

import 'package:flutter/material.dart';

class PresetCreatorPopup extends StatefulWidget {
  const PresetCreatorPopup({super.key});

  @override
  State<PresetCreatorPopup> createState() => _PresetCreatorPopupState();
}

class _PresetCreatorPopupState extends State<PresetCreatorPopup> {
  String currentText = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save preset'),
      content: TextField(
        onChanged: (value) {
          currentText = value;
        },
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Save preset'),
          onPressed: () {
            log(currentText);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
