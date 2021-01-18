import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pa_messenger/pages/verify_phone.dart';
import 'package:pa_messenger/utils/dialog_utils.dart';
import 'package:pa_messenger/widgets/app_button.dart';
import 'package:pa_messenger/widgets/app_text_field.dart';

class Login extends StatefulWidget {

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final _phoneNumberController = TextEditingController();
  bool showLoading = false;

  _logIn(BuildContext context) {
    if (_phoneNumberController.text == null || _phoneNumberController.text.isEmpty) {
      return;
    }

    setState(() { showLoading = true; });

    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phoneNumberController.text,
      verificationCompleted: (credential) async {
        await showOkDialog(context, title: 'Success!', content: 'Phone authentication was successful');
        await FirebaseAuth.instance.signInWithCredential(credential);

        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);

        setState(() { showLoading = false; });
      },
      verificationFailed: (error) {
        setState(() { showLoading = false; });
        showOkDialog(context, 
          title: 'An error occurred!',
          content: error.message,
        );
      },
      codeSent: (verificationId, forceResendingToken) {
        setState(() { showLoading = false; });
        Navigator.of(context).pushNamed('/verify-phone', arguments: VerifyPhoneArgs(verificationId));
      },
      codeAutoRetrievalTimeout: (verificationId) {  }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('PA Messenger'),
            Text('Login'),

            Container(height: 15),

            AppTextField(
              controller: _phoneNumberController,
              labelText: 'Phone number',
              keyboardType: TextInputType.phone,
            ),

            Container(height: 15),

            if (!showLoading)
              PrimaryButton(
                onPressed: () => _logIn(context),
                minWidth: double.infinity,
                text: 'Verify',
              ),

            if (showLoading)
              Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
