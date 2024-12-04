import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:github_sign_in_plus/github_sign_in_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Authentication App - GitHub Login',
      home: const SplashPage(),
    );
  }
}

/// Tela inicial para verificar o estado do login.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('github_token');

    if (token != null) {
      final userInfo = await _fetchGitHubUser(token);
      if (userInfo != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WelcomePage(userInfo: userInfo),
          ),
        );
        return;
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
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
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
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

      if (token != null) {
        // Salva o token para login persistente
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('github_token', token);

        final userInfo = await _fetchGitHubUser(token);

        if (userInfo != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WelcomePage(userInfo: userInfo),
            ),
          );
        }
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
        title: const Text('Authentication App'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _signInWithGitHub(context),
          child: SizedBox(
            width: 150,
            child: Row(
              children: [
                Image.network(
                  'https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png',
                  height: 24,
                  width: 24,
                ),
                SizedBox(width: 8),
                const Text('Login com GitHub')
              ],
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF8621F8),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  final Map<String, dynamic> userInfo;

  const WelcomePage({super.key, required this.userInfo});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('github_token');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String username = userInfo['login'] ?? 'Usuário';
    final String? name = userInfo['name'];
    final String? email = userInfo['email'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication App'),
      ),
      body: Center(
        child: Padding(
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
                onPressed: () => _logout(context),
                child: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8935E8),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

