import 'package:flutter/material.dart';
import 'package:learning_dart/GUI/views/custom_scroll_view_view.dart';
import 'package:learning_dart/library/DeviceManager/device_manager.dart';
import 'package:learning_dart/GUI/views/main_view/device_button.dart';
import 'package:learning_dart/GUI/views/main_view/main_view_header.dart';
import 'package:learning_dart/GUI/views/preset_creator_view/preset_creator_view.dart';
import 'package:learning_dart/GUI/views/preset_list_view/preset_list_view.dart';
import 'package:learning_dart/GUI/elements/columns.dart';

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

Widget _groupButtons() {
  return SliverToBoxAdapter(
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
  );
}

Widget _presetsMenuTitle(BuildContext context) {
  return SliverToBoxAdapter(
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
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return const PresetListView();
                      },
                    ),
                  );
                },
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
  );
}

Widget _deviceMenuTitle(BuildContext context) {
  return SliverToBoxAdapter(
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
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return const PresetCreatorView();
                      },
                    ),
                  );
                },
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
  );
}

_deviceMenu() {
  return SliverToBoxAdapter(
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
  );
}

class MainView extends CustomScrollViewView {

  MainView({super.key})
      : super(listBuilder: (context) {
          return [
            const MainViewHeader(),
            _groupButtons(),
            _groupButtons(),
            _groupButtons(),
            _groupButtons(),
            _groupButtons(),
            _groupButtons(),
            _groupButtons(),
            _groupButtons(),
            _groupButtons(),
            _groupButtons(),
          ];
        });
}
