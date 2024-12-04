<img width=100% src="https://capsule-render.vercel.app/api?type=waving&color=8621F8&height=120&section=header"/>

# N3 - Authentication App
Aplicativo criado para avaliação final (N3) de Desenvolvimento Mobile, tratando-se de um aplicativo de autenticação de usuário. O desenvolvimento deste aplicativo foi realizado em equipe, contanto com o Daniel Fernando Costa Pereira, Laura Heloísa Luchez e Matheus Eduardo Pedrelli Mauricio.

## Objetivo e Funções do Aplicativo 
O "Authentication App" é um aplicativo mobile, compatível com dispositivos móveis Android, que permite aos usuários realizar ações de **login e logout por meio do provedor GitHub**. Essa persistência de login é armazenada e controlada no banco de dados **FireBase**, portanto o usuário continua logado mesmo ao reiniciar o app.
O aplicativo conta com as seguintes telas e funcionalidades:

- **Tela de Login:** Possui a logo do GitHub (provedor escolhido) e um botão que direciona o usuário para a tela de autenticação do provedor.
- **Tela Principal:** Após se autenticar, o usuário é redirecionado para uma tela que exibe o username utilizado no GitHub, o nome do usuário cadastrado na plataforma e um botão que permite ao usuário se desconectar do aplicativo, retornando assim à tela de login.

## Tipos de Tratamento de Erros do GitHub
A partir da [documentação do flutter](https://pub.dev/documentation/github_sign_in_plus/latest/github_sign_in_plus/GitHubSignInResultStatus.html), podemos listar abaixo os três tratamentos de erro que o GitHub fornece para realizar a autenticação do usuário. Neste projeto, a validação foi feita por meio da constante GitHubSignInResultStatus.ok - caso não seja retornado o "ok", será exibido o "cancelled" ou "failed" conforme a situação. 

- **Ok:** The login was successful.
- **Cancelled:** The user cancelled the login flow, usually by closing the login dialog.
- **Failed:** The login completed with an error and the user couldn't log in for some reason.

## Dependências e suas Versões
As dependências listadas abaixo foram utilizadas no desenvolvimento deste projeto, responsáveis pelo login através do provedor GitHub e pela persistência de login ao encerrar o aplicativo.
- [github_sign_in_plus → 0.0.2](https://pub.dev/packages/github_sign_in_plus/versions)
> Biblioteca para integração com o GitHub para autenticação social.
- [shared_preferences → 2.3.3](https://pub.dev/packages/shared_preferences)
> Utilizada para persistência de dados no dispositivo.


## Configuração e Importação do projeto
Antes de configurar o projeto na máquina, é necessário verificar as versões que forem utilizadas neste projeto. Abaixo estão listadas as versões adequadas, é possível verificar as versões instalados do flutter e Dart executando `flutter --version`.
- Versão Flutter → 3.24.4
- Versão Dart → 3.5.4
- Versão Mínima do SDK → 23

### Clone o repositório
Para clonar o repositório do github, execute o seguinte comando na raiz do projeto: 
```ruby
git clone https://github.com/seu-usuario/seu-repositorio.git
cd seu-repositorio
```

## Linguagens utilizadas
![Flutter](https://img.shields.io/badge/-Flutter-0D1117?style=for-the-badge&logo=flutter&labelColor=0D1117&textColor=0D1117)&nbsp;
![Dart](https://img.shields.io/badge/-Dart-0D1117?style=for-the-badge&logo=dart&labelColor=0D1117&textColor=0D1117)&nbsp;
![Firebase](https://img.shields.io/badge/-Firebase-0D1117?style=for-the-badge&logo=firebase&labelColor=0D1117&textColor=0D1117)&nbsp;

<img width=100% src="https://capsule-render.vercel.app/api?type=waving&color=8621F8&height=120&section=footer"/>
