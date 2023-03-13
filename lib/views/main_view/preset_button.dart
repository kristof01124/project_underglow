import 'package:flutter/material.dart';
import 'package:learning_dart/library/PresetManager/preset_manager.dart';

ButtonStyle presetButtonStyle = TextButton.styleFrom(
  foregroundColor: Colors.white,
  backgroundColor: Colors.blue,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
    side: const BorderSide(color: Colors.black),
  ),
);

class PresetButton extends StatelessWidget {
  const PresetButton({super.key, required this.presetName});

  final String presetName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 7.5,
      child: TextButton(
        onPressed: () {
          if (presetName == defaultPresetName) {
            // TODO: Push the preset creator view to the screen.
          }
          PresetManager.run(presetName);
        },
        style: presetButtonStyle,
        child: Text(presetName),
      ),
    );
  }
}
