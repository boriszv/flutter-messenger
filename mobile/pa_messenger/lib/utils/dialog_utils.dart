
import 'package:flutter/material.dart';

Future showOkDialog(BuildContext context, { String title, String content}) async {
  await showDialog(context: context, child: AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: [
      FlatButton(child: Text('Ok'), onPressed: () {
        Navigator.of(context).pop();
      })
    ],
  ));
}