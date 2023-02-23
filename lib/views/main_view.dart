/*
  This is gonna be the Main View of the App.
*/
import 'package:flutter/material.dart';

import '../widgets/columns.dart';

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
    TODO
  */
}

List<String> _getAllAvailablePresets() {
  return ['[NONE]', '[NONE]', '[NONE]', '[NONE]', '[NONE]', '[NONE]'];
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

class _MainViewPresets extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<String> presets = _getAllAvailablePresets();
    List<Widget> widgetList = [];
    for (String value in presets) {
      widgetList.add(
        TextButton(onPressed: () {}, child: Text(value)),
      );
    }
    return Expanded(
      child: Columns(2, widgetList),
    );
  }
}

/*
class _MainViewEntities extends StatelessWidget {
  // TODO
}
*/

class _MainViewState extends State<StatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          _MainViewAppBar(),
          _MainViewKillButton(),
          _MainViewPresets()
        ],
      ),
    );
  }
}

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<StatefulWidget> createState() => _MainViewState();
}
