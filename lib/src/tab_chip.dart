import 'package:flutter/material.dart';

class TabChip extends StatelessWidget {
  const TabChip({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
    this.selectedColor,
    this.backgroundColor,
  });

  final Widget label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final Color? selectedColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        canvasColor: Colors.transparent,
        chipTheme: ChipThemeData(
          backgroundColor: selected ? selectedColor : backgroundColor ?? Colors.transparent,
        ),
      ),
      child: ChoiceChip(
        label: label,
        selected: selected,
        onSelected: onSelected,
        elevation: 0,
        pressElevation: 0,
        selectedColor: selectedColor,
      ),
    );
  }
}
