import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {

  final String labelText;
  final String hintText;
  final TextInputType keyboardType;

  AppTextField({
    this.labelText,
    this.hintText,
    this.keyboardType
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: Theme.of(context).cursorColor,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        labelText: labelText,
        hintText: hintText
      ),
    );
  }
}
