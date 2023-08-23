import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:learning_dart/GUI/views/gui_view.dart';

class ListViewView extends GuiView {
  ListViewView({required List<Widget> children, super.key})
      : super(
          body: ListView(
            children: children,
          ),
        );
}
