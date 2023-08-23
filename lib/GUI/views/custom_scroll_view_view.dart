import 'package:flutter/material.dart';
import 'package:learning_dart/GUI/views/gui_view.dart';

class CustomScrollViewView extends GuiView {
  CustomScrollViewView({
    required List<Widget> Function(BuildContext context) listBuilder,
    super.key,
  }) : super(
          builder: (context) {
            return CustomScrollView(
              slivers: listBuilder.call(context),
              key: key,
            );
          },
        );
}
