import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:github_sign_in_plus/github_sign_in_plus.dart';

Future<void> main() async{

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GitHubSignIn gitHubSignIn = GitHubSignIn(
    clientId: 'bbd975f97f953c6e1843',
    clientSecret: '609fb6441354c8d148248ae2cab0673b4ce7f1d5',
    redirectUrl: 'https://mobile-n3.firebaseapp.com/__/auth/handler',
    title: 'GitHub Connection',
    centerTitle: false,
  );

  @override
  void initState() {
    super.initState();
  }

  void _gitHubSignIn(BuildContext context) async {
    var result = await gitHubSignIn.signIn(context);
    switch (result.status) {
      case GitHubSignInResultStatus.ok:
        print(result.token);
        break;

      case GitHubSignInResultStatus.cancelled:
      case GitHubSignInResultStatus.failed:
        print(result.errorMessage);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Github Plus Example"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _gitHubSignIn(context);
          },
          child: const Text("GitHub Connection"),
        ),
      ),
    );
  }
}
