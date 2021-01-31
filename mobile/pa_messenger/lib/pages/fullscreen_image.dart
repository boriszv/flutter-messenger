import 'dart:typed_data';

import 'package:flutter/material.dart';

class FullscreenImage extends StatelessWidget {

  final ImageProvider provider;

  FullscreenImage(this.provider);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Image(
        image: provider,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.fitWidth,
      ),
    );
  }

  factory FullscreenImage.url(String url, { double height, double width, }) {
    return FullscreenImage(NetworkImage(url));
  }

  factory FullscreenImage.memory(Uint8List data, { double height, double width, }) {
    return FullscreenImage(MemoryImage(data));
  }
}
