import 'package:flutter/material.dart';
import 'package:pa_messenger/utils/dialog_utils.dart';
import 'package:pa_messenger/widgets/app_button.dart';
import 'package:pa_messenger/widgets/app_round_image.dart';
import 'package:permission_handler/permission_handler.dart';

class AddContact extends StatefulWidget {
  @override
  _AddContactState createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {

  bool isGranted = false;
  bool showPermissionsLoading = false;

  @override
  void initState() { 
    super.initState();
    _checkPermissions();
  }

  _checkPermissions() async {
    setState(() { showPermissionsLoading = true; });

    final status = await Permission.contacts.status;

    setState(() {
      isGranted = status.isGranted;
      showPermissionsLoading = false;
    });
  }

  _requestPermissions() async {
    final permission = Permission.contacts;

    var status = await permission.status;
    if (status.isPermanentlyDenied || status.isRestricted) {
      await showOkDialog(context, title: 'Permission denied', content: 'You will have to enable the contact permission from settings for this to work');
    }

    if (status.isUndetermined || status.isDenied) {
      status = await permission.request();
    }

    setState(() { isGranted = status.isGranted; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: Text('Select contact'),
        actions: [
          if (isGranted)
            IconButton(icon: Icon(Icons.search), onPressed: () {},)
        ],
      ),
      body: Builder(
        builder: (context) {
          if (showPermissionsLoading) return Center(child: CircularProgressIndicator());
          if (!isGranted) return _permissionDenied();

          return ListView.builder(
            itemBuilder: (context, index) {
              return _ContactListItem();
            },
            itemCount: 22,
          );
        },
      ),
    );
  }

  _permissionDenied() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text('You cannot access this page without the Contacts permission', textAlign: TextAlign.center,),
      PrimaryButton(
        text: 'Request',
        onPressed: () => _requestPermissions(),
      )
    ],
  );
}

class _ContactListItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _image(),
                Padding(
                  padding: EdgeInsets.only(left: 14.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _title(context, 'Aleksandra Stankovic'),
                        Container(height: 4),
                        _latestMessageText(context, 'Hey there I use this app!')
                      ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _image() => AppRoundImage(
        'https://thispersondoesnotexist.com/image',
        width: 35,
        height: 35,
      );

  _title(BuildContext context, String text) {
    return Text(text,
        style: Theme.of(context)
            .textTheme
            .subtitle1
            .apply(fontSizeDelta: -3, fontWeightDelta: 3));
  }

  _latestMessageText(BuildContext context, String text) {
    return Text(text, style: Theme.of(context).textTheme.caption.apply(fontSizeDelta: -2));
  }
}
