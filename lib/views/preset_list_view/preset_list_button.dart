import 'package:flutter/material.dart';
import 'package:learning_dart/library/PresetManager/preset_manager.dart';

class PresetListButton extends StatefulWidget {
  final int presetIndex;
  final int? currentIndex;
  final State<StatefulWidget> listViewParent;

  const PresetListButton(
      {super.key,
      required this.presetIndex,
      required this.listViewParent,
      this.currentIndex});

  @override
  State<PresetListButton> createState() => _PresetListButtonState();
}

class _PresetListButtonState extends State<PresetListButton> {
  @override
  Widget build(BuildContext context) {
    String presetName = PresetManager.getPresets()[widget.presetIndex];
    return SizedBox(
      height: MediaQuery.of(context).size.height / 6,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.red,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
          ),
          onPressed: () {
            if (widget.currentIndex != null) {
              PresetManager.menuPresets[widget.currentIndex as int] =
                  presetName;
            }
            Navigator.of(context).pop();
          },
          onLongPress: () {
            // TODO: popup
          },
          child: Text(presetName),
        ),
      ),
    );
  }
}
