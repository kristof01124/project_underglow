import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:learning_dart/library/AnimationCreator/animation_creator_implementations.dart';
import 'package:learning_dart/library/DeviceManager/device_manager.dart';
import 'package:learning_dart/library/AnimationCreator/single_animation_creator.dart';
import 'package:learning_dart/widgets/folded_header.dart';

class DetailedLedView extends StatefulWidget {
  const DetailedLedView({super.key, required this.devices});
  final List<Device> devices;

  @override
  State<DetailedLedView> createState() => _DetailedLedViewState();
}

class _DetailedLedViewState extends State<DetailedLedView> {
  String? value;
  late Map<String, SimpleAnimationCreator> animations;
  SimpleAnimationCreator? animationCreatorBody;

  @override
  void initState() {
    super.initState();
    // TODO: Get the available animations for the device
    animations = {'Fill': FillEffectCreator()};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const FoldedHeader(),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
              child: DropdownButton(
                value: value,
                items: animations.values
                    .map((e) => DropdownMenuItem(
                          value: e.name,
                          child: Text(e.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    this.value = value;
                    log(value ?? '');
                    animationCreatorBody = animations[value ?? ''];
                  });
                },
              ),
            ),
          ),
          animationCreatorBody?.build() ?? Container(),
        ],
      ),
    );
  }
}
