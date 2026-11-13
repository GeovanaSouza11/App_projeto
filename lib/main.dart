import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_preview_plus/device_preview_plus.dart';
import 'firebase_options.dart';

import 'core/app_routes.dart';
import 'core/dependencias.dart';

import 'view/cadastrar_usuario_view.dart';
import 'view/login_view.dart';
import 'view/perfil_view.dart';
import 'view/recuperar_senha_view.dart';
import 'view/sobre_view.dart';
import 'view/tela_inicial_view.dart';
import 'view/registrar_problema_view.dart';
import 'view/minhas_solicitacoes_view.dart';
import 'view/sugestoes_view.dart';
import 'view/detalhes_solicitacao_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  configurarDependencias();

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static const Color corPrimaria = Color(0xFFE7000B);

  @override
  Widget build(BuildContext context) {
    final bool usuarioLogado = FirebaseAuth.instance.currentUser != null;

    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      title: 'Ribeirão Resolve',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: corPrimaria,
          primary: corPrimaria,
        ),
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: usuarioLogado ? const TelaInicialView() : const LoginView(),
      routes: {
        AppRoutes.cadastrarUsuario: (context) => const CadastrarUsuarioView(),
        AppRoutes.login: (context) => const LoginView(),
        AppRoutes.perfil: (context) => const PerfilView(),
        AppRoutes.recuperarSenha: (context) => const RecuperarSenhaView(),
        AppRoutes.sobre: (context) => const SobreView(),
        AppRoutes.telaInicial: (context) => const TelaInicialView(),
        AppRoutes.registrarProblema: (context) => const RegistrarProblemaView(),
        AppRoutes.minhasSolicitacoes: (context) => const MinhasSolicitacoesView(),
        AppRoutes.detalhesSolicitacao: (context) => const DetalhesSolicitacoesView(),
        AppRoutes.sugestoes: (context) => const SugestoesView(),
      },
    );
  }
}
