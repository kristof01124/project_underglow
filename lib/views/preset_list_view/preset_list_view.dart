import 'package:flutter/material.dart';
import 'package:learning_dart/library/PresetManager/preset_manager.dart';
import 'package:learning_dart/views/preset_list_view/preset_list_button.dart';
import 'package:learning_dart/widgets/folded_header.dart';

import '../../widgets/columns.dart';

class PresetListView extends StatefulWidget {
  final int? currentIndex;

  const PresetListView({super.key, this.currentIndex});

  @override
  State<PresetListView> createState() => _PresetListViewState();
}

class _PresetListViewState extends State<PresetListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const FoldedHeader(),
          Expanded(
            child: ListView(
              children: [
                Columns(
                  numberOfColumns: 2,
                  children: [
                    for (int i = 0; i < PresetManager.getPresets().length; i++)
                      PresetListButton(
                        currentIndex: widget.currentIndex,
                        presetIndex: i,
                        listViewParent: this,
                      ),
                  ],
                ),
                
              ],
            ),
          ),
        ],
      ),
    );
  }
}
