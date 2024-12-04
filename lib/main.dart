import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:github_sign_in_plus/github_sign_in_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';


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
    // Realiza a busca do token no storage do dispositivo
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('github_token');
    // Caso encontre o token, solicita ao github os dados do user
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

  // Função que busca os dados do user na api do github
  // Recebe como parametro o token do user e retorna o body
  // da request (os dados do user)
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

  // Estado inicial da pagina checa o status do login
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Enquanto o login é verificado um indicador circular
  // é renderizado
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// Widget da tela de login
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// Cria um objeto do tipo GithubSingIn
// Este cujo se encarrega de realizar a autenticação
// Utilizando o github como provider
class _LoginPageState extends State<LoginPage> {
  final GitHubSignIn gitHubSignIn = GitHubSignIn(
    clientId: 'Ov23limrERaj9llnuFmH',
    clientSecret: '450b5f862a8e966f9b3b6a1a1896434781aeb61b',
    redirectUrl: 'https://mobile-n3.firebaseapp.com/__/auth/handler',
  );

  // Função que realiza a autenticação recebe como parametro
  // o context e retorna não retorna nada pois "troca"
  // a pagina na navegação, da tela de login para a
  // welcome page
  Future<void> _signInWithGitHub(BuildContext context) async {
    final result = await gitHubSignIn.signIn(context);
    if (result.status == GitHubSignInResultStatus.ok) {
      final token = result.token;

      // Se o github sign in retornar o token, significa
      // que a autenticação deu certo
      if (token != null) {
        // Salva o token no storage do dispositivo para persistencia
        // após fechar o aplicativo
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
      // Se o githubSignIn não retornar o token, algum erro
      // ocorreu e cai nessa clausa else, que apenas informa
      // que houve erro na autenticação
      print("Erro ao fazer login: ${result.errorMessage}");
    }
  }

  // Função que busca as informações do usuário passando o token
  // como parâmetro e retorna um Map de string:dinamic, isso 
  // significa com os campos do json não estão mapeados e podem
  // ser absolutamente qualquer tipo de valor, como um int, double
  // string, etc
  Future<Map<String, dynamic>?> _fetchGitHubUser(String token) async {
    const url = 'https://api.github.com/user';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    // Verifica se a requisição foi bem sucedida com status 200 ok
    if (response.statusCode == 200) {
      // se sim retorna o corpo da requisição em formato Map<String, dynamic> 
      return json.decode(response.body);
    } else {
      // Se não, retorna null e informa que houve erro ao buscar as informações
      print('Erro ao obter informações do usuário: ${response.statusCode}');
      return null;
    }
  }

  //build da tela principal com um botão para logar e a logo do github
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

// Widget da tela de boas vindas após o login com sucesso
class WelcomePage extends StatelessWidget {
  //user info retornado pela api do github
  final Map<String, dynamic> userInfo;

  const WelcomePage({super.key, required this.userInfo});

  //Função para realizar o logout
  Future<void> _logout(BuildContext context) async {
    // Busca o token no storage do dispositivo e o remove
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('github_token');

    // Limpa os cookies para forçar o logout
    // E solicitar o login no github novamente
    // após o logout
    final cookieManager = WebviewCookieManager();
    await cookieManager.clearCookies();

    // Altera a tela atual para a tela de login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  // widgets que mostram as informações do usuário logado
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
                  backgroundColor: Color(0xFF8621F8),
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

