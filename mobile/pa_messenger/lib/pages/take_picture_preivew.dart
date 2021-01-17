import 'dart:io';

import 'package:flutter/material.dart';

class TakePicturePreviewArgs {
  final String imagePath;
  TakePicturePreviewArgs(this.imagePath);
}

class TakePicturePreview extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments as TakePicturePreviewArgs;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: Text('Image preview'),
      ),
      body: Container(
        color: Colors.grey.shade900,
        child: Stack(
          children: [
            Center(child: Image.file(File(args.imagePath), fit: BoxFit.cover,)),

            Container(
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(bottom: 45),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _floatingButton(context, heroTag: 'tag1', icon: Icons.check, valueToReturn: true),
                  Container(width: 15),
                  _floatingButton(context, heroTag: 'tag2', icon: Icons.close, valueToReturn: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _floatingButton(BuildContext context, {String heroTag, IconData icon, bool valueToReturn}) => FloatingActionButton(
    heroTag: heroTag,
    elevation: 0,
    child: Icon(icon, color: Theme.of(context).primaryColor),
    onPressed: () {Navigator.of(context).pop(valueToReturn);},
    backgroundColor: Colors.grey.shade900,
  );
}
