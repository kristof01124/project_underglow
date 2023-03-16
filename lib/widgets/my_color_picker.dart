import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:learning_dart/widgets/columns.dart';

class ColorPickerPalette extends StatelessWidget {
  final List<Color> availableColors;
  final int numberOfRows;
  final void Function(Color) onColorChanged;

  const ColorPickerPalette(
      {super.key,
      required this.availableColors,
      required this.numberOfRows,
      required this.onColorChanged});

  @override
  Widget build(BuildContext context) {
    return BlockPicker(
      pickerColor: Colors.red,
      onColorChanged: onColorChanged,
      availableColors: availableColors,
      layoutBuilder: (context, colors, child) {
        return Columns(
          numberOfColumns: colors.length ~/ numberOfRows,
          children: [
            for (Color color in colors)
              Expanded(
                child: child(color),
              )
          ],
        );
      },
      itemBuilder:
          (Color color, bool isCurrentColor, void Function() changeColor) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                  color: color.withOpacity(0.8),
                  offset: const Offset(1, 2),
                  blurRadius: 5)
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: changeColor,
              borderRadius: BorderRadius.circular(50),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 210),
                opacity: isCurrentColor ? 1 : 0,
                child: Icon(Icons.done,
                    color: useWhiteForeground(color)
                        ? Colors.white
                        : Colors.black),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MyColorPickerState extends State<MyColorPicker> {
  HSVColor color = HSVColor.fromColor(Colors.red);

  _MyColorPickerState();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.all(height / 400),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 0,
              horizontal: height / 20,
            ),
            child: SizedBox(
              height: min(width, height * 7 / 10),
              width: width,
              child: ColorPickerArea(
                color.withValue(1.0),
                (color) {
                  widget.onColorChanged?.call(color.toColor());
                  setState(
                    () {
                      this.color = color;
                    },
                  );
                },
                PaletteType.hueWheel,
              ),
            ),
          ),
          SizedBox(
            height: height / 9,
            width: width,
            child: ColorPickerPalette(
              onColorChanged: (color) {
                setState(
                  () {
                    widget.onColorChanged?.call(color);
                    this.color = HSVColor.fromColor(color);
                  },
                );
              },
              availableColors: const [
                Colors.red,
                Colors.green,
                Colors.blue,
                Colors.black,
              ],
              numberOfRows: 1,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: height / 200),
            child: SizedBox(
              height: height / 8,
              width: width,
              child: ColorPickerSlider(
                TrackType.value,
                color,
                (color) {
                  widget.onColorChanged?.call(color.toColor());
                  setState(
                    () {
                      this.color = this.color.withValue(color.value);
                    },
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

class MyColorPicker extends StatefulWidget {
  const MyColorPicker({super.key, this.onColorChanged});
  final void Function(Color)? onColorChanged;

  @override
  State<StatefulWidget> createState() {
    return _MyColorPickerState();
  }
}
