import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contact/contacts.dart';
import 'package:pa_messenger/utils/dialog_utils.dart';
import 'package:pa_messenger/widgets/app_button.dart';
import 'package:pa_messenger/widgets/app_round_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contact/contact.dart';

class AddContact extends StatefulWidget {
  @override
  _AddContactState createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {

  static final _searchController = TextEditingController();

  bool isGranted = false;
  bool showLoadingIndicator = false;
  bool isSearching = false;

  List<Contact> allContacts;
  List<Contact> filteredContacts;

  @override
  void initState() { 
    super.initState();
    _checkPermissions();

    _searchController.addListener(() {
      _performSearch(_searchController.text);
    });
  }

  _checkPermissions() async {
    setState(() { showLoadingIndicator = true; });

    final status = await Permission.contacts.status;

    setState(() {
      isGranted = status.isGranted;
      showLoadingIndicator = false;
    });

    if (status.isGranted) await _fetchContacts();
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

    if (status.isGranted) await _fetchContacts();
  }

  _fetchContacts() async {
    setState(() { showLoadingIndicator = true; });
    final contactsSource = Contacts.listContacts();

    final contacts = <Contact>[];
    while (await contactsSource.moveNext()) {
      contacts.add(await contactsSource.current);
    }

    setState(() {
      this.allContacts = contacts;
      this.filteredContacts = contacts;
      showLoadingIndicator = false;
    });
  }

  var isCheckingIfContactExists = false;

  _addContactIfExists(Contact contact) async {
    setState(() { isCheckingIfContactExists = true; });

    final phones = contact.phones.map((x) => x.value.replaceAll(' ', '')).toList();
    final result = await FirebaseFirestore.instance.collection('users').where('phoneNumber', whereIn: phones).get();

    setState(() { isCheckingIfContactExists = false; });

    if (result.size == 0) {
      final invite = await showYesNoDialog(context,
        title: 'Contact ${contact.displayName} is not using this app',
        content: 'Would you like to invite them?',
      );
      // TOOD Add invite logic
      return;
    }

    // TODO Create conversation
  }

  _performSearch(String text) {
    filteredContacts = allContacts;
    setState(() {
      filteredContacts = filteredContacts.where((x) => (x.displayName ?? '').toLowerCase().contains(text) || x.phones.any((x) => x.value.replaceAll(' ', '').contains(text))).toList();
    });
  }

  _beginSearch() {
    setState(() { isSearching = true; });
  }

  _stopSearch() {
    _searchController.text = '';
    setState(() { isSearching = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: Builder(
          builder: (context) {
            if (!isSearching) return Text('Select contact');

            return TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                focusColor: Colors.white,
                fillColor: Colors.white,
                hintStyle: TextStyle(color: Colors.white),
                hoverColor: Colors.white,
                hintText: 'Search...'
              ),
            );
          },
        ),
        actions: [
          if (isGranted && !isSearching)
            IconButton(icon: Icon(Icons.search), onPressed: _beginSearch),
          if (isSearching)
            IconButton(icon: Icon(Icons.close), onPressed: _stopSearch,)
        ],
      ),
      body: Builder(
        builder: (context) {
          if (showLoadingIndicator) return Center(child: CircularProgressIndicator());
          if (!isGranted) return _permissionDenied();

          return ListView.builder(
            itemBuilder: (context, index) {
              if (filteredContacts[index].displayName == null || filteredContacts[index].phones.isEmpty) return Container();
              return _ContactListItem(
                name: filteredContacts[index].displayName,
                imageBytes: filteredContacts[index].avatar,
                phoneNumber: filteredContacts[index].phones.first.value ?? '',
                onTap: () {
                  _addContactIfExists(filteredContacts[index]);
                },
              );
            },
            itemCount: filteredContacts.length,
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

  final String name;
  final String phoneNumber;
  final Uint8List imageBytes;
  final Function onTap;

  _ContactListItem({
    @required this.name,
    @required this.imageBytes,
    @required this.phoneNumber,
    @required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _image(context),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _title(context, name),
                    _phoneNumber(context, phoneNumber)
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _image(BuildContext context) {
    if (imageBytes == null) {
      return Container(child: Icon(Icons.account_circle, size: 35, color: Colors.grey.shade900));
    }

    return AppRoundImage.memory(
      imageBytes,
      width: 35,
      height: 35,
    );
  }

  _title(BuildContext context, String text) {
    return Text(text,
        style: Theme.of(context)
            .textTheme
            .subtitle1
            .apply(fontSizeDelta: -3, fontWeightDelta: 3));
  }

  _phoneNumber(BuildContext context, String text) {
    return Text(text, style: Theme.of(context).textTheme.caption.apply(fontSizeDelta: -2));
  }
}
