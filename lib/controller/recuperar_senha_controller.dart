import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecuperarSenhaController extends ChangeNotifier {
  bool validarEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());
  }

  Future<void> enviarRecuperacao(String email) async {
    final emailLimpo = email.trim();
    if (emailLimpo.isEmpty) {
      throw Exception('Por favor, informe o seu e-mail cadastrado.');
    }

    if (!validarEmail(emailLimpo)) {
      throw Exception('Informe um endereço de e-mail em formato válido.');
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailLimpo);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw Exception('O formato do e-mail informado é inválido.');
        case 'user-not-found':
          throw Exception('Nenhuma conta encontrada com este endereço de e-mail.');
        case 'too-many-requests':
          throw Exception('Muitas solicitações seguidas. Tente novamente mais tarde.');
        case 'network-request-failed':
          throw Exception('Sem conexão com a internet. Verifique sua rede.');
        default:
          throw Exception('Não foi possível enviar o e-mail de recuperação (${e.code}).');
      }
    }
  }
}
