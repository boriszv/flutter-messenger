
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

Future showYesNoDialog(BuildContext context, { String title, String content, String yes = 'Yes', String no = 'No'}) async {
  await showDialog(context: context, child: AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: [
      FlatButton(child: Text(yes), onPressed: () {
        Navigator.of(context).pop(true);
      }),
      FlatButton(child: Text(no), onPressed: () {
        Navigator.of(context).pop(false);
      }),
    ],
  ));
}
