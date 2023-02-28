import 'package:flutter/material.dart';

List<String> _getAllSavedPresets() {
  return [
    "Preset 1",
    "Preset 2",
    "Preset 3",
    "Preset 4",
  ];
}

void _setPreset(int index, String presetName) {}

void _openPresetCreatorWindow() {}

class _SetPresetViewButton extends StatelessWidget {
  final String presetName;
  final int currentPreset;

  const _SetPresetViewButton(
      {required this.presetName, required this.currentPreset});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        _setPreset(currentPreset, presetName);
      },
      onLongPress: () {
        _openPresetCreatorWindow();
      },
      child: Text(
        presetName,
      ),
    );
  }
}

class SetPresetView extends StatelessWidget {
  final int currentPreset;

  const SetPresetView({super.key, required this.currentPreset});

  @override
  Widget build(BuildContext context) {
    var presets = _getAllSavedPresets();
    List<Widget> children = [];
    for (var title in presets) {
      children.add(_SetPresetViewButton(
        presetName: title,
        currentPreset: currentPreset,
      ));
    }
    children.add(TextButton(
      child: const Text('Add new preset...'),
      onPressed: () {
        /*
          TODO: make this view update dynamically when the preset creator changes something.
        */
        _openPresetCreatorWindow();
      },
    ));
    return ListView(
      children: children,
    );
  }
}
