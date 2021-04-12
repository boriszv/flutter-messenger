import 'package:flutter/material.dart';
import 'package:pa_messenger/pages/conversation_list.dart';
import 'package:pa_messenger/pages/profile.dart';
import 'package:pa_messenger/widgets/app_bottom_nav.dart';

import 'add_contact_email.dart';
import 'add_contact_phone.dart';

class AppContainer extends StatefulWidget {
  @override
  _AppContainerState createState() => _AppContainerState();
}

class _AppContainerState extends State<AppContainer> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AppBottomNav(selectedIndex, (index) {
        setState(() {
          selectedIndex = index;
        });
      }),
      body: Builder(builder: (context) {
        switch (selectedIndex) {
          case 0:
            return ConversationList();
          case 1:
            return AddContactEmail();
          case 2:
            return Profile();
          default:
            throw new Exception('Unknown page with index ' + selectedIndex.toString());
        }
      }),
    );
  }
}
