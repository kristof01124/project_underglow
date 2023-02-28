import 'dart:developer';

import 'package:flutter/material.dart';

class Columns extends StatelessWidget {
  final int numberOfColumns;
  final List<Widget> children;

  const Columns(this.numberOfColumns, this.children, {super.key});

  @override
  Widget build(BuildContext context) {
    final columnLength = (children.length + numberOfColumns - 1) ~/ numberOfColumns;
    List<Widget> outputChildren = [];
    for (int i = 0; i < numberOfColumns; i++) {
      int end = (i + 1) * columnLength;
      if (end > children.length) {
        end = children.length;
      }
      outputChildren.add(
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children.sublist(i * columnLength, end),
          ),
        ),
      );
    }
    Widget output = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: outputChildren,
    );
    return output;
  }
}
