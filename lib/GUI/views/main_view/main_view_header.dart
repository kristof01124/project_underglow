import 'dart:io';

import 'package:flutter/material.dart';

class MainViewHeader extends StatelessWidget {
  const MainViewHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: MediaQuery.of(context).size.height / 2,
      collapsedHeight: MediaQuery.of(context).size.height / 10,
      flexibleSpace: FlexibleSpaceBar(
        expandedTitleScale: 1,
        titlePadding: const EdgeInsets.all(5),
        title: Center(
          child: Image.file(
            File(
                'C:\\Users\\krist\\Downloads\\Project_Underlow_logo.png'), // This is obviously temporary
          ),
        ),
      ),
    );
  }
}
