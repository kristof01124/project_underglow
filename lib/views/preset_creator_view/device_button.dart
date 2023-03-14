
import 'package:flutter/material.dart';
import 'package:learning_dart/widgets/stateful_slider.dart';

import '../../library/DeviceManager/device_manager.dart';

const Color onBackgroundColor = Colors.green, offBackgroundColor = Colors.red;

const TextStyle textStyle = TextStyle(
  fontSize: 20,
  shadows: [
    Shadow(
      offset: Offset(0.5, 0.5),
      blurRadius: 0.5,
    ),
  ],
);

const EdgeInsets textPadding = EdgeInsets.all(8);

// Slider parameters
const Color activeColor = Colors.red;
const Color inactiveColor = Colors.purple;

// Container decoration
const double borderRadius = 20;

void _setBrightness(double value, Device device) {
  // Send change brightness request to device
}

class DeviceButton extends StatefulWidget {
  final Device device;

  const DeviceButton({super.key, required this.device});

  @override
  State<DeviceButton> createState() => _DeviceButtonState();
}

class _DeviceButtonState extends State<DeviceButton> {
  @override
  Widget build(BuildContext context) {
    LedDeviceState state = DeviceManager.getData(widget.device);
    Color currentBackgroundColor = offBackgroundColor;
    if (state.on) {
      currentBackgroundColor = onBackgroundColor;
    }
    return Container(
      decoration: BoxDecoration(
        color: currentBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: textPadding,
                      child: Text(
                        widget.device.name,
                        style: textStyle,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: textPadding,
                      child: Icon(Icons.power_settings_new),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: StatefulSlider(
                  value: state.brightness.toDouble(),
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                  onChanged: (value) {
                    setState(() {
                      _setBrightness(value, widget.device);
                    });
                  },
                  min: 0,
                  max: 255,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: textPadding,
                  child: Text(
                    state.animationName,
                    style: textStyle,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
