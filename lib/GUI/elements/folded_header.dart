import 'package:flutter/material.dart';

class FoldedHeader extends StatelessWidget {
  const FoldedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 9,
      color: Colors.blue,
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          child: const Icon(
            Icons.exit_to_app,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
