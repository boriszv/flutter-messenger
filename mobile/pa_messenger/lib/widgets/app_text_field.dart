import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {

  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final TextInputType keyboardType;
  final int maxLines;
  final int minLines;
  final bool alignLabelWithHint;
  final bool obscureText;


  AppTextField({
    this.labelText,
    this.hintText,
    this.keyboardType,
    this.minLines = 1,
    this.maxLines,
    this.alignLabelWithHint = false,
    this.controller,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorColor: Theme.of(context).cursorColor,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        labelText: labelText,
        hintText: hintText,
        alignLabelWithHint: alignLabelWithHint
      ),
    );
  }
}
