import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GitHubAuthScreen extends StatefulWidget {
  @override
  _GitHubAuthScreenState createState() => _GitHubAuthScreenState();
}

class _GitHubAuthScreenState extends State<GitHubAuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signInWithGitHub() async {
    try {
      // Crie a credencial do GitHub com o token
      final GithubAuthProvider githubProvider = GithubAuthProvider();

      // Adicione permissões específicas do GitHub, se necessário
      githubProvider.addScope("read:user");
      githubProvider.setCustomParameters({
        'allow_signup': 'false', // Impede novos usuários de se cadastrarem
      });

      // Inicie o fluxo de autenticação
      final UserCredential userCredential =
          await _auth.signInWithProvider(githubProvider);

      // Obtenha as informações do usuário
      final User? user = userCredential.user;
      print("Usuário autenticado: ${user?.displayName}");
    } catch (e) {
      print("Erro durante a autenticação: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("GitHub Authentication")),
      body: Center(
        child: ElevatedButton(
          onPressed: _signInWithGitHub,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                'https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png',
                height: 24,
              ),
              SizedBox(width: 8),
              Text("Sign in with GitHub"),
            ],
          ),
        ),
      ),
    );
  }
}

