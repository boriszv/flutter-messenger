import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pa_messenger/models/appUser.dart';
import 'package:pa_messenger/widgets/app_button.dart';
import 'package:pa_messenger/widgets/app_round_image.dart';
import 'package:pa_messenger/widgets/app_text_field.dart';

class Profile extends StatefulWidget {

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  final _nameController = TextEditingController();
  final _aboutMeController = TextEditingController();

  String imageUrl;
  var showLoading = false;
  var showSaving = false;

  @override
  void initState() {
    _fetchConversations();
    super.initState();
  }

  DocumentReference _buildQuery() {
    return FirebaseFirestore.instance.doc('users/${FirebaseAuth.instance.currentUser.uid}');
  }

  Future<void> _fetchConversations() async {
    setState(() { showLoading = true; });

    final result = await _buildQuery().get();
    final user = AppUser.fromMap(result.data());

    _nameController.text = user.name;
    _aboutMeController.text = user.bio;

    setState(() {
      showLoading = false;
      imageUrl = user.imageUrl;
    });
  }

  Future _saveChanges() async {
    setState(() { showSaving = true; });

    try {
      final user = AppUser(
        bio: _aboutMeController.text,
        name: _nameController.text,
        imageUrl: imageUrl
      );
      await _buildQuery().set(user.toMap(), SetOptions(merge: true));
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Profile saved')));

    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Profile was not saved')));

    } finally {
      setState(() { showSaving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          child: Builder(
            builder: (context) {
              if (showLoading) {
                return Center(child: CircularProgressIndicator());
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (imageUrl != null) ...[
                    _image(imageUrl),
                    SizedBox(height: 10),
                    _changePhoto(context),
                  ],

                  SizedBox(height: 10),
                  _name(),
                  SizedBox(height: 15),
                  _aboutMe(),
                  SizedBox(height: 40),

                  if (!showSaving)
                    _save(),

                  if (showSaving)
                    CircularProgressIndicator(),
                ],
              );
            }
          ),
        ),
      )
    );
  }

  _image(String imageUrl) => AppRoundImage(
    imageUrl,
    width: 80,
    height: 80,
  );

  _changePhoto(BuildContext context) => InkWell(
    child: Padding(
      padding: EdgeInsets.all(8.0),
      child: Text('Change photo', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),),
    ),
    onTap: () {},
  );

  _name() => AppTextField(
    controller: _nameController,
    labelText: 'Name',
    keyboardType: TextInputType.text,
  );

  _aboutMe() => AppTextField(
    controller: _aboutMeController,
    labelText: 'About me',
    keyboardType: TextInputType.multiline,
    minLines: 3,
    alignLabelWithHint: true,
  );

  _save() => PrimaryButton(
    onPressed: () {
      _saveChanges();
    },
    borderRadius: 30,
    minWidth: double.infinity,
    text: 'Save',
  );
}