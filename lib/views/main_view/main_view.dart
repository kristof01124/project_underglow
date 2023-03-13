import 'package:flutter/material.dart';
import 'package:learning_dart/library/DeviceManager/device_manager.dart';
import 'package:learning_dart/library/PresetManager/preset_manager.dart';
import 'package:learning_dart/views/main_view/device_button.dart';
import 'package:learning_dart/views/main_view/main_view_header.dart';
import 'package:learning_dart/views/main_view/preset_button.dart';
import 'package:learning_dart/widgets/columns.dart';

// PARAMETERS

const titleColor = Color.fromRGBO(102, 102, 102, 1.0);

const textStyleLeft = TextStyle(color: titleColor, fontSize: 25, shadows: [
  Shadow(
    blurRadius: 2,
    offset: Offset(1, 1),
    color: titleColor,
  ),
]);

const textStyleRight = TextStyle(
  color: titleColor,
  fontSize: 20,
  shadows: [
    Shadow(
      blurRadius: 2,
      offset: Offset(1, 1),
      color: titleColor,
    ),
  ],
);

const deviceButtonPadding = EdgeInsets.all(5.0);
const titlePadding = EdgeInsets.symmetric(horizontal: 8);

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const MainViewHeader(),
          SliverToBoxAdapter(
            child: Row(
              children: [
                for (Widget widget in [interiorButton, exteriorButton])
                  Expanded(
                    child: Padding(
                      padding: deviceButtonPadding,
                      child: widget,
                    ),
                  ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: titlePadding,
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
                        padding: deviceButtonPadding,
                        child: PresetButton(presetName: e),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: titlePadding,
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
                      padding: deviceButtonPadding,
                      child: DeviceButton(
                        devices: [e],
                        title: e.name,
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
