import 'package:flutter/material.dart';
import 'package:pa_messenger/widgets/app_button.dart';
import 'package:pa_messenger/widgets/app_round_image.dart';
import 'package:pa_messenger/widgets/app_text_field.dart';

class Profile extends StatelessWidget {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _image(),
              SizedBox(height: 10),
              _changePhoto(context),
              SizedBox(height: 10),
              _name(),
              SizedBox(height: 15),
              _aboutMe(),
              SizedBox(height: 40),
              _save(),
            ],
          ),
        ),
      )
    );
  }

  _image() => AppRoundImage(
    'https://thispersondoesnotexist.com/image',
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
    labelText: 'Name',
    keyboardType: TextInputType.text,
  );

  _aboutMe() => AppTextField(
    labelText: 'About me',
    keyboardType: TextInputType.multiline,
    minLines: 3,
    alignLabelWithHint: true,
  );

  _save() => PrimaryButton(
    onPressed: () {

    },
    borderRadius: 30,
    minWidth: double.infinity,
    text: 'Save',
  );
}