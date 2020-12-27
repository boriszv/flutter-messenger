import 'package:flutter/material.dart';

class AppRoundImage extends StatelessWidget {

  final String url;
  final double height;
  final double width;

  AppRoundImage(this.url, {
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Image.network(
        url,
        height: height,
        width: width,
      ),
    );
  }
}
