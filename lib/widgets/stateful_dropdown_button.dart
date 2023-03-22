import 'package:flutter/material.dart';

class StatefulDropdownButton extends StatefulWidget {
  final List<DropdownMenuItem<dynamic>> items;
  final Widget? hint;
  final Widget? disabledHint;
  final ValueChanged<dynamic>? onChanged;
  final DropdownButtonBuilder? selectedItemBuilder;
  final DropdownButtonBuilder? dropdownButtonBuilder;
  final Widget? underline;
  final bool isDense;
  final bool isExpanded;
  final TextStyle? style;
  final dynamic value;

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
  dynamic value;

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: value,
      key: widget.key,
      hint: widget.hint,
      disabledHint: widget.disabledHint,
      items: widget.items,
      onChanged: (value) {
        setState(
          () {
            this.value = value;
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
