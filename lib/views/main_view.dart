import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class PresetsWidget extends StatelessWidget {
  final List<String> presets;

  const PresetsWidget(this.presets, {super.key});

  Widget _makeWidgetFromStringList(List<String> data) {
    List<Widget> children = [];
    for (String name in data) {
      children.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: TextButton(
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.white),
                    minimumSize: MaterialStatePropertyAll(Size(10000000, 0)),
                  ),
                  onPressed: () {
                    /*
                      TODO: If name is [Done], than open up the preset creator view, if not than play the preset with the given name.
                    */
                  },
                  child: Text(name),
                ),
          ),
        ),
      );
    }
    return Expanded(
      child: Column(
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _makeWidgetFromStringList(
              presets.sublist(0, presets.length ~/ 2),
            ),
            _makeWidgetFromStringList(
              presets.sublist(presets.length ~/ 2),
            ),
          ],
        ),
      ],
    );
  }
}

class _MainViewState extends State<MainView> {
  @override
  Widget build(BuildContext context) {
    final halfHeight = MediaQuery.of(context).size.height / 2;
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: halfHeight,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.file(File('assets/logo.png')),
            ),
          ),
          SliverToBoxAdapter(
            child: Expanded(
              child: Container(
                height: halfHeight,
                color: Colors.red,
                child: const Expanded(
                  child: PresetsWidget([
                    'Full RGB Wave',
                    '[NONE]',
                    '[NONE]',
                    '[NONE]',
                    '[NONE]',
                    '[NONE]',
                  ]),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: halfHeight,
              color: Colors.green,
            ),
          )
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
