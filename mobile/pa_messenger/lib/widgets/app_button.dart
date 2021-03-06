import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {

  final VoidCallback onPressed;
  final double minWidth;
  final String text;
  final double borderRadius;
  final bool disabled;

  PrimaryButton({
    @required this.onPressed,
    this.minWidth,
    this.text,
    this.borderRadius,
    this.disabled = false
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: disabled ? null : onPressed,
      elevation: 0,
      focusElevation: 0,
      highlightElevation: 0,
      minWidth: minWidth,
      color: Theme.of(context).primaryColor,
      child: Text(text, style: TextStyle(color: Colors.white)),

      shape: borderRadius != null
        ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius))
        : null
    );
  }
}
