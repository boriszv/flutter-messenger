import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pa_messenger/utils/dialog_utils.dart';
import 'package:pa_messenger/widgets/app_button.dart';
import 'package:pa_messenger/widgets/app_text_field.dart';

class VerifyPhoneArgs {
  final String verificationId;
  VerifyPhoneArgs(this.verificationId);
}

class VerifyPhone extends StatefulWidget {

  @override
  _VerifyPhoneState createState() => _VerifyPhoneState();
}

class _VerifyPhoneState extends State<VerifyPhone> {

  final _codeController = TextEditingController();
  bool showLoading = false;

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
              controller: _codeController,
              labelText: 'Verification Code',
              keyboardType: TextInputType.phone,
            ),

            Container(height: 15),

            showLoading
              ? CircularProgressIndicator()
              : PrimaryButton(
                onPressed: () => _verifyCode(context),
                minWidth: double.infinity,
                text: 'Verify',
              )
          ],
        ),
      ),
    );
  }

  _verifyCode(BuildContext context) async {
    if (_codeController.text == null || _codeController.text.isEmpty) {
      return;
    }

    setState(() { showLoading = true; });

    final args = ModalRoute.of(context).settings.arguments as VerifyPhoneArgs;
    final credential = PhoneAuthProvider.credential(verificationId: args.verificationId, smsCode: _codeController.text);

    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);

    } on FirebaseAuthException catch (e) {
      await showOkDialog(context, title: 'An error occurred', content: e.message);
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  
    } finally {
      setState(() { showLoading = false; });
    }
  }
}