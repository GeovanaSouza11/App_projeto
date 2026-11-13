import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginController extends ChangeNotifier {
  String _email = '';
  String _senha = '';
  bool _mostrarSenha = false;

  String get email => _email;
  String get senha => _senha;
  bool get mostrarSenha => _mostrarSenha;

  bool get camposPreenchidos =>
      _email.trim().isNotEmpty && _senha.isNotEmpty;

  void atualizarEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void atualizarSenha(String senha) {
    _senha = senha;
    notifyListeners();
  }

  void alternarVisibilidadeSenha() {
    _mostrarSenha = !_mostrarSenha;
    notifyListeners();
  }

  /// Autentica o usuário no Firebase Auth sem aplicar .trim() na senha (mantendo consistência com o cadastro).
  Future<void> realizarLogin({
    required String email,
    required String senha,
  }) async {
    final emailLimpo = email.trim();
    if (emailLimpo.isEmpty || senha.isEmpty) {
      throw Exception('Preencha seu e-mail e sua senha.');
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailLimpo,
        password: senha,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          throw Exception('E-mail ou senha incorretos.');
        case 'invalid-email':
          throw Exception('O formato do e-mail é inválido.');
        case 'user-disabled':
          throw Exception('Esta conta de usuário foi desativada.');
        case 'too-many-requests':
          throw Exception('Muitas tentativas. Aguarde alguns instantes e tente novamente.');
        case 'network-request-failed':
          throw Exception('Falha de conexão. Verifique sua internet.');
        default:
          throw Exception('Erro ao realizar login (${e.code}).');
      }
    }
  }
}
