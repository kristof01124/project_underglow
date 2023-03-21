import 'package:flutter/material.dart';

class StatefulDropdownButton extends StatefulWidget {
  final List<DropdownMenuItem<dynamic>> items;
  final dynamic value;
  final Widget? hint;
  final Widget? disabledHint;
  final ValueChanged<dynamic>? onChanged;
  final DropdownButtonBuilder? selectedItemBuilder;
  final DropdownButtonBuilder? dropdownButtonBuilder;
  final Widget? underline;
  final bool isDense;
  final bool isExpanded;
  final TextStyle? style;

  const StatefulDropdownButton({
    super.key,
    required this.items,
    required this.value,
    this.hint,
    this.disabledHint,
    this.onChanged,
    this.selectedItemBuilder,
    this.dropdownButtonBuilder,
    this.underline,
    this.isDense = false,
    this.isExpanded = false,
    this.style,
  });

  @override
  State<StatefulDropdownButton> createState() => _StatefulDropdownButtonState();
}

class _StatefulDropdownButtonState extends State<StatefulDropdownButton> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      key: widget.key,
      hint: widget.hint,
      disabledHint: widget.disabledHint,
      items: widget.items,
      onChanged: (value) {
        setState(
          () {
            widget.onChanged?.call(value);
          },
        );
      },
      selectedItemBuilder: widget.selectedItemBuilder,
      underline: widget.underline,
      isDense: widget.isDense,
      style: widget.style,
    );
  }
}
