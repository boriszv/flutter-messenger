import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pa_messenger/utils/dialog_utils.dart';
import 'package:pa_messenger/widgets/app_button.dart';
import 'package:pa_messenger/widgets/app_text_field.dart';

class EmailLogin extends StatefulWidget {

  @override
  _EmailLoginState createState() => _EmailLoginState();
}

class _EmailLoginState extends State<EmailLogin> {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool showLoading = false;

  _logIn(BuildContext context) async {
    if (_emailController.text == null || _emailController.text.isEmpty) {
      return;
    }
    if (_passwordController.text == null || _passwordController.text.isEmpty) {
      return;
    }

    setState(() { showLoading = true; });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text
      );

      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);

    } on FirebaseAuthException catch (e) {
      showOkDialog(context, 
        title: 'An error occurred when logging in',
        content: e.message,
      );

    } finally {
      setState(() { showLoading = false; });
    }
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
              controller: _emailController,
              labelText: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),

            Container(height: 15),

            AppTextField(
              controller: _passwordController,
              labelText: 'Password',
              obscureText: true,
              minLines: 1,
              maxLines: 1,
            ),

            Container(height: 15),

            if (!showLoading)
              PrimaryButton(
                onPressed: () => _logIn(context),
                minWidth: double.infinity,
                text: 'Log in',
              ),

            if (showLoading)
              Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
