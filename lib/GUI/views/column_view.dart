import 'package:flutter/material.dart';
import 'package:learning_dart/GUI/views/gui_view.dart';

class ColumnView extends GuiView {
  ColumnView({required List<Widget> children, super.key})
      : super(
          body: Column(
            key: key,
            children: children,
          ),
        );
}
