import 'package:flutter/material.dart';
import 'package:learning_dart/views/main_view/main_view_header.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const MainViewHeader(),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 2000,
              child: Container(
                color: Colors.red,
              ),
            ),
          )
        ],
      ),
    );
  }
}
