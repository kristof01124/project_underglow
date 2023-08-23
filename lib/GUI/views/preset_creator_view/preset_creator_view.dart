import 'package:flutter/material.dart';
import 'package:learning_dart/library/DeviceManager/device_manager.dart';
import 'package:learning_dart/GUI/views/preset_creator_view/device_button.dart';
import 'package:learning_dart/GUI/views/preset_creator_view/preset_creator_popup.dart';
import 'package:learning_dart/GUI/elements/folded_header.dart';

double heightRatio = 1 / 6;

const EdgeInsets padding = EdgeInsets.symmetric(vertical: 5, horizontal: 15);

const ButtonStyle savePresetButtonStyle = ButtonStyle();

class PresetCreatorView extends StatelessWidget {
  const PresetCreatorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const FoldedHeader(),
          SizedBox(
            height: MediaQuery.of(context).size.height / 10,
            child: Row(
              children: [
                const Expanded(
                  child: Padding(
                    padding: padding,
                    child: Text(
                      'Devices',
                      style: TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Color.fromARGB(255, 102, 102, 102),
                              offset: Offset(0, 0),
                              blurRadius: 0.5,
                            )
                          ]),
                    ),
                  ),
                ),
                Padding(
                  padding: padding,
                  child: TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const PresetCreatorPopup();
                        },
                      );
                    },
                    style: savePresetButtonStyle,
                    child: const Text('Save current preset'),
                  ),
                ),
              ],
            ),
          ),
          for (Device device in DeviceManager.getDevices())
            Padding(
              padding: padding,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * heightRatio,
                child: DeviceButton(device: device),
              ),
            ),
        ],
      ),
    );
  }
}
