import 'package:flutter/material.dart';
import 'package:pa_messenger/widgets/app_button.dart';
import 'package:pa_messenger/widgets/app_text_field.dart';

class Login extends StatelessWidget {
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
              labelText: 'Phone number',
              keyboardType: TextInputType.phone,
            ),

            Container(height: 15),

            PrimaryButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/conversations', (_) => false);
              },
              minWidth: double.infinity,
              text: 'Verify',
            )
          ],
        ),
      ),
    );
  }
}
