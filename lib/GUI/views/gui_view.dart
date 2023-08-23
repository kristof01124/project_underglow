import 'package:flutter/material.dart';

abstract class GuiView extends StatelessWidget {
  const GuiView({super.key, required this.builder});

  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: builder.call(context),
    );
  }
}
