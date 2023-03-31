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
  ),
);

ButtonStyle ledDeviceUnavailableStyle = TextButton.styleFrom(
  foregroundColor: Colors.black,
  backgroundColor: Colors.grey,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
    side: const BorderSide(color: Colors.black),
  ),
);

DeviceButton interiorButton = DeviceButton(
  devices: DeviceManager.getInteriorDevices(),
  onStyle: ledDeviceOnStyle,
  offStyle: ledDeviceOffStyle,
  unavailableStyle: ledDeviceUnavailableStyle,
  title: 'Interior',
);

DeviceButton exteriorButton = DeviceButton(
  devices: DeviceManager.getExteriorDevices(),
  onStyle: ledDeviceOnStyle,
  offStyle: ledDeviceOffStyle,
  unavailableStyle: ledDeviceUnavailableStyle,
  title: 'Exterior',
);

class DeviceButton extends StatefulWidget {
  final List<Device> devices;
  final ButtonStyle onStyle, offStyle;
  final ButtonStyle? unavailableStyle;
  final String title;

  const DeviceButton({
    super.key,
    required this.devices,
    required this.onStyle,
    required this.offStyle,
    this.unavailableStyle,
    required this.title,
  });

  @override
  State<StatefulWidget> createState() {
    return _DeviceButtonState();
  }
}

class _DeviceButtonState extends State<DeviceButton> {
  @override
  Widget build(BuildContext context) {
    ButtonStyle style = widget.offStyle;
    if (widget.devices.isEmpty && widget.unavailableStyle != null) {
      style = (widget.unavailableStyle as ButtonStyle);
    }
    for (Device device in widget.devices) {
      if ((DeviceManager.getData(device)).on) {
        style = widget.onStyle;
      }
    }
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 7.5,
      child: TextButton(
        onPressed: () {
          setState(
            () {},
          );
        },
        onLongPress: () {
          if (widget.devices.length == 1) {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return DeviceManager.getDetailedView(widget.devices[0]);
            }));
          }
        },
        style: style,
        child: Text(widget.title),
      ),
    );
  }
}
