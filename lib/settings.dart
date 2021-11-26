import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            GoogleSignIn _googleSignIn = GoogleSignIn(
              scopes: [
                'email',
                'profile',
                'https://www.googleapis.com/auth/calendar.events.readonly',
                // 'https://www.googleapis.com/auth/gmail.readonly', // notify of events/purchases
                'https://www.googleapis.com/auth/contacts.readonly',
                'https://www.googleapis.com/auth/user.birthday.read',
              ],
            );
            try {
              var user = await _googleSignIn.signIn();
              debugPrint(user?.displayName);
            } catch (error) {
              print(error);
            }
          },
          child: const Text('Google Sign In'),
        ),
      ),
    );
  }
}
