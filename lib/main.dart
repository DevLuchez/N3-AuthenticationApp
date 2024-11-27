import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:github_sign_in_plus/github_sign_in_plus.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Login Example',
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GitHubSignIn gitHubSignIn = GitHubSignIn(
    clientId: 'Ov23limrERaj9llnuFmH',
    clientSecret: '450b5f862a8e966f9b3b6a1a1896434781aeb61b',
    redirectUrl: 'https://mobile-n3.firebaseapp.com/__/auth/handler',
  );

  Future<void> _signInWithGitHub(BuildContext context) async {
    final result = await gitHubSignIn.signIn(context);
    if (result.status == GitHubSignInResultStatus.ok) {
      final token = result.token;
      final userInfo = await _fetchGitHubUser(token!);

      if (userInfo != null) {
        // Redireciona para a página de boas-vindas
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WelcomePage(userInfo: userInfo),
          ),
        );
      }
    } else {
      print("Erro ao fazer login: ${result.errorMessage}");
    }
  }

  Future<Map<String, dynamic>?> _fetchGitHubUser(String token) async {
    const url = 'https://api.github.com/user';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Erro ao obter informações do usuário: ${response.statusCode}');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login com GitHub'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _signInWithGitHub(context),
          child: const Text('Login com GitHub'),
        ),
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  final Map<String, dynamic> userInfo;

  const WelcomePage({super.key, required this.userInfo});

  @override
  Widget build(BuildContext context) {
    final String username = userInfo['login'] ?? 'Usuário';
    final String? name = userInfo['name'];
    final String? email = userInfo['email'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bem-vindo!'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(userInfo['avatar_url']),
            ),
            const SizedBox(height: 20),
            Text(
              'Olá, $username!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (name != null)
              Text(
                'Nome: $name',
                style: const TextStyle(fontSize: 18),
              ),
            if (email != null)
              Text(
                'E-mail: $email',
                style: const TextStyle(fontSize: 18),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Retorna para a página inicial
                Navigator.pop(context);
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

