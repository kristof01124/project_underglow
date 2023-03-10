import 'package:flutter/material.dart';
import 'package:learning_dart/library/DeviceManager/device_manager.dart';
import 'package:learning_dart/library/PresetManager/preset_manager.dart';
import 'package:learning_dart/views/main_view/device_button.dart';
import 'package:learning_dart/views/main_view/main_view_header.dart';
import 'package:learning_dart/views/main_view/preset_button.dart';
import 'package:learning_dart/widgets/columns.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const MainViewHeader(),
          Columns(
            numberOfColumns: 2,
            children: PresetManager.menuPresets
                .map(
                  (e) => PresetButton(presetName: e),
                )
                .toList(),
          ),
          Columns(
            numberOfColumns: 2,
            children: DeviceManager.getDevices()
                .map(
                  (e) => DeviceButton(
                    device: e,
                    onStyle: ledDeviceOnStyle,
                    offStyle: ledDeviceOffStyle,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
