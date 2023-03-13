import 'package:flutter/material.dart';
import 'package:learning_dart/library/DeviceManager/device_manager.dart';
import 'package:learning_dart/library/PresetManager/preset_manager.dart';
import 'package:learning_dart/views/main_view/device_button.dart';
import 'package:learning_dart/views/main_view/main_view_header.dart';
import 'package:learning_dart/views/main_view/preset_button.dart';
import 'package:learning_dart/widgets/columns.dart';

const textStyleLeft = TextStyle(
    color: Color.fromRGBO(102, 102, 102, 1.0),
    fontSize: 25,
    shadows: [
      Shadow(
        blurRadius: 2,
        offset: Offset(1, 1),
        color: Color.fromRGBO(102, 102, 102, 1.0),
      ),
    ]);

const textStyleRight = TextStyle(
  color: Color.fromRGBO(102, 102, 102, 1.0),
  fontSize: 20,
  shadows: [
    Shadow(
      blurRadius: 2,
      offset: Offset(1, 1),
      color: Color.fromRGBO(102, 102, 102, 1.0),
    ),
  ],
);

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const MainViewHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
              ),
              child: Row(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Presets',
                      style: textStyleLeft,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'More',
                          style: textStyleRight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              child: Columns(
                numberOfColumns: 2,
                children: PresetManager.menuPresets
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.all(5),
                        child: PresetButton(presetName: e),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
              ),
              child: Row(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Devices',
                      style: textStyleLeft,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'More',
                          style: textStyleRight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Columns(
              numberOfColumns: 2,
              children: DeviceManager.getDevices()
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.all(5),
                      child: DeviceButton(
                        device: e,
                        onStyle: ledDeviceOnStyle,
                        offStyle: ledDeviceOffStyle,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
