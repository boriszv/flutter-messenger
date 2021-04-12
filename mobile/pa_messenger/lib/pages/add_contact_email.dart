import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contact/contacts.dart';
import 'package:pa_messenger/models/appUser.dart';
import 'package:pa_messenger/models/conversation.dart';
import 'package:pa_messenger/models/conversationUser.dart';
import 'package:pa_messenger/pages/chat.dart';
import 'package:pa_messenger/utils/dialog_utils.dart';
import 'package:pa_messenger/widgets/app_button.dart';
import 'package:pa_messenger/widgets/app_round_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contact/contact.dart';

class AddContactEmail extends StatefulWidget {
  @override
  _AddContactEmailState createState() => _AddContactEmailState();
}

class _AddContactEmailState extends State<AddContactEmail> {

  static final _searchController = TextEditingController();

  List<AppUser> users = [];
  List<AppUser> filteredUsers = [];

  bool showLoadingIndicator = false;
  bool isSearching = false;

  @override
  void initState() { 
    super.initState();
    _searchController.addListener(() {
      _performSearch(_searchController.text);
    });
    _fetchUsers();
  }

  _fetchUsers() async {
    setState(() { showLoadingIndicator = true; });

    try {
      final result = await FirebaseFirestore.instance.collection('users').limit(30).get();
      final users = result.docs.map((e) => AppUser.fromMap(e.id, e.data())).toList();
      setState(() {
        this.users = users;
        filteredUsers = users;
      });

    } catch (e) {

    } finally {
      setState(() { showLoadingIndicator = false; });
    }
  }

  var isCheckingIfContactExists = false;
  _addUser(AppUser user) async {
    final userIds = [user.id, FirebaseAuth.instance.currentUser.uid]..sort((a, b) => a.compareTo(b));
    final userIdsHash = userIds.join('');

    final conversationResult = await FirebaseFirestore.instance
      .collection('conversations')
      .where('userIdsHash', isEqualTo: userIdsHash)
      .where('userIds', arrayContains: FirebaseAuth.instance.currentUser.uid)
      .get();

    if (conversationResult.docs.isNotEmpty) {
      await showOkDialog(context,
        title: 'Existing converastion',
        content: 'You already have a conversation with this user',
      );
      return;
    }

    final args = ChatArgs(chatType: ChatType.CreateConversation, userToSendMessageToId: user.id, conversation: Conversation(
      users: [
        ConversationUser(
          imageUrl: user.imageUrl,
          userId: user.id,
          userName: user.name,
        )
      ]
    ));
    Navigator.of(context).pushNamed('/chat', arguments: args);
  }

  _performSearch(String text) async {
    if (text == null || text.trim().isEmpty) {
      setState(() {
        filteredUsers = users;
      });
      return;
    }

    setState(() { showLoadingIndicator = true; });

    final result = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: text).get();
    if (result.docs.isEmpty) {
      setState(() {
        filteredUsers = [];
        showLoadingIndicator = false;
      });
      return;
    }

    setState(() {
      filteredUsers = [AppUser.fromMap(result.docs.first.id, result.docs.first.data())];
      showLoadingIndicator = false;
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
            if (!isSearching) return Text('Add user');

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
          if (!isSearching)
            IconButton(icon: Icon(Icons.search), onPressed: _beginSearch),
          if (isSearching)
            IconButton(icon: Icon(Icons.close), onPressed: _stopSearch,)
        ],
      ),
      body: Builder(
        builder: (context) {
          if (showLoadingIndicator) return Center(child: CircularProgressIndicator());

          return ListView.builder(
            itemBuilder: (context, index) {
              return _ContactListItem(
                name: filteredUsers[index].name,
                imageUrl: filteredUsers[index].imageUrl,
                onTap: () {
                  _addUser(filteredUsers[index]);
                },
              );
            },
            itemCount: filteredUsers.length,
          );
        },
      ),
    );
  }
}

class _ContactListItem extends StatelessWidget {

  final String name;
  final String imageUrl;
  final Function onTap;

  _ContactListItem({
    @required this.name,
    @required this.imageUrl,
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
    if (imageUrl == null) {
      return Container(child: Icon(Icons.account_circle, size: 35, color: Colors.grey.shade900));
    }

    return AppRoundImage.url(
      imageUrl,
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
