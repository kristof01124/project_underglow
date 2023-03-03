/*
  This is gonna be the Main View of the App.
*/
import 'package:flutter/material.dart';

import '../constants.dart';
import '../widgets/columns.dart';

void _openDetailedLedView(LedEntity entity) {
  /*
    TODO: Should open up the detailed led View tied to the specific entity.
    Requirement: Implementation of detailed led view.
  */
}

List<LedEntity> _getAllAvailableEntities() {
  List<LedEntity> out = [
    LedEntity("Underglow", "Rgb wave", true, 200),
    LedEntity("Left index", "Rgb wave", true, 200),
    LedEntity("Right index", "Rgb wave", false, 200),
    LedEntity("Grill", "Rgb wave", true, 200),
    LedEntity("Foot light", "Rgb wave", false, 200),
  ];
  return out;
}

String _getPresetTitelForIndex(index) {
  return '[NONE]';
}

void _togglePowerState(LedEntity entity) {}

LedEntity _getLedEntityByName(String name) {
  return LedEntity(name, 'Rgb wave', true, 200);
}

void _playPreset(int index) {}

void _openPresetSetterView(int index) {}

final ledEntityButtonOnStyle = TextButton.styleFrom(
  backgroundColor: Colors.green,
);

final ledEntityButtonOffStyle = TextButton.styleFrom(
  backgroundColor: Colors.red,
);

class _MainViewAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenData = MediaQuery.of(context);
    return SliverAppBar(
      expandedHeight: screenData.size.height * 4 / 10,
      collapsedHeight: screenData.size.height * 1 / 10,
      flexibleSpace: const FlexibleSpaceBar(
        background: Center(
          child: Text('Placeholder'),
        ),
      ),
    );
  }
  /*
    TODO: Stylization of the taskbar
  */
}

class _MainViewKillButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 5,
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Kill button'),
          onPressed: () {},
        ),
      ),
    );
  }
}

class _MainViewPresetButtonState extends State<_MainViewPresetButton> {
  @override
  Widget build(BuildContext context) {
    String title = _getPresetTitelForIndex(widget.index);
    return Expanded(
      child: TextButton(
        style:
            TextButton.styleFrom(minimumSize: const Size(double.infinity, 0)),
        onPressed: () {
          if (_getPresetTitelForIndex(widget.index) == '[none]') {
            _openPresetSetterView(widget.index);
            // TODO: Whe the setter view changes the preset the main view should dynamically change too
          } else {
            _playPreset(widget.index);
          }
        },
        onLongPress: () => _openPresetSetterView(widget.index),
        child: Text(title),
      ),
    );
  }
}

class _MainViewPresetButton extends StatefulWidget {
  const _MainViewPresetButton({required this.index});
  final int index;

  @override
  State<StatefulWidget> createState() => _MainViewPresetButtonState();
}

class _MainViewPresets extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [];
    for (int i = 0; i < numberOfPresetButtons; i++) {
      widgetList.add(
        _MainViewPresetButton(
          index: i,
        ),
      );
    }
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.purple,
        height: MediaQuery.of(context).size.height / 2,
        child: Columns(
          numberOfColumns: 2,
          children: widgetList,
        ),
      ),
    );
  }
}

class LedEntity {
  final String name;
  final String currentlyPlayingAnimation;
  final bool isOn;
  final int brightness;

  LedEntity(
      this.name, this.currentlyPlayingAnimation, this.isOn, this.brightness);
}

class _LedEntitySimpleButtonState extends State<LedEntitySimpleButton> {
  _LedEntitySimpleButtonState();
  @override
  Widget build(BuildContext context) {
    LedEntity entity = _getLedEntityByName(widget.entity.name);
    final style =
        entity.isOn ? ledEntityButtonOnStyle : ledEntityButtonOffStyle;
    return TextButton(
      onPressed: () {
        setState(
          () {
            _togglePowerState(entity);
          },
        );
      },
      onLongPress: () {
        _openDetailedLedView(entity);
      },
      style: style,
      child: Row(children: [
        Text(entity.name),
        Text(entity.currentlyPlayingAnimation),
      ]),
    );
  }
}

class LedEntitySimpleButton extends StatefulWidget {
  const LedEntitySimpleButton(this.entity, {super.key});
  final LedEntity entity;

  @override
  State<StatefulWidget> createState() {
    return _LedEntitySimpleButtonState();
  }
}

/*
  TODO: Make this widget refresh when the entities change
*/
class _MainViewEntities extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final entities = _getAllAvailableEntities();
    List<Widget> widgetEntites = [];
    for (var element in entities) {
      widgetEntites.add(
        SizedBox(
          height: MediaQuery.of(context).size.height / 5,
          child: LedEntitySimpleButton(
            element,
          ),
        ),
      );
    }
    return SliverToBoxAdapter(
      child: Columns(
        numberOfColumns: 2,
        children: widgetEntites,
      ),
    );
  }
}

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          _MainViewAppBar(),
          _MainViewKillButton(),
          _MainViewPresets(),
          _MainViewEntities(),
        ],
      ),
    );
  }
}
