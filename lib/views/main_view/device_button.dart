import 'package:flutter/material.dart';
import 'package:learning_dart/library/DeviceManager/device_manager.dart';

ButtonStyle ledDeviceOnStyle = TextButton.styleFrom(
  foregroundColor: Colors.black,
  backgroundColor: Colors.green,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
    side: const BorderSide(color: Colors.black),
  ),
);

ButtonStyle ledDeviceOffStyle = TextButton.styleFrom(
    foregroundColor: Colors.black,
    backgroundColor: Colors.red,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: const BorderSide(color: Colors.black),
    ));

class DeviceButton extends StatefulWidget {
  final Device device;
  final ButtonStyle onStyle, offStyle;

  const DeviceButton({
    super.key,
    required this.device,
    required this.onStyle,
    required this.offStyle,
  });

  @override
  State<StatefulWidget> createState() {
    return _DeviceButtonState();
  }
}

class _DeviceButtonState extends State<DeviceButton> {
  @override
  Widget build(BuildContext context) {
    ButtonStyle style = widget.onStyle;
    if (!(DeviceManager.getData(widget.device) as LedDeviceState).on) {
      style = widget.offStyle;
    }
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 6,
      child: TextButton(
        onPressed: () {
          setState(
            () {
              LedDeviceState data =
                  (DeviceManager.getData(widget.device) as LedDeviceState);
              data.on = !data.on;
            },
          );
        },
        onLongPress: () {
          // get the detailed device view
          // ignore: unused_local_variable
          Widget detailedView = DeviceManager.getDetailedView(widget.device);
          // TODO: then navigate to it
        },
        style: style,
        child: Text(widget.device.name),
      ),
    );
  }
}
