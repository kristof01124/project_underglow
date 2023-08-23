import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:learning_dart/library/PresetManager/preset_manager.dart';
import 'package:learning_dart/GUI/views/preset_list_view/preset_list_view.dart';


ButtonStyle presetButtonStyle = TextButton.styleFrom(
  foregroundColor: Colors.white,
  backgroundColor: Colors.blue,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
    side: const BorderSide(color: Colors.black),
  ),
);

class PresetButton extends StatelessWidget {
  const PresetButton(
      {super.key,
      required this.presetButtonIndex,
      required this.mainViewState});

  final State<StatefulWidget> mainViewState;
  final int presetButtonIndex;

  void navigateToPresetListView(BuildContext context) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => PresetListView(
          currentIndex: presetButtonIndex,
        ),
      ),
    )
        .then(
      (value) {
        // ignore: invalid_use_of_protected_member
        mainViewState.setState(
          () {
            log(PresetManager.menuPresets.toString());
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String presetName = PresetManager.menuPresets[presetButtonIndex];
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 7.5,
      child: TextButton(
        onPressed: () {
          if (presetName == defaultPresetName) {
            navigateToPresetListView(context);
            return;
          }
          PresetManager.run(presetName);
        },
        onLongPress: () {
          navigateToPresetListView(context);
        },
        style: presetButtonStyle,
        child: Text(presetName),
      ),
    );
  }
}
