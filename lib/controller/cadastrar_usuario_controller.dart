import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CadastrarUsuarioController extends ChangeNotifier {
  /// Valida se a senha possui no mínimo 6 caracteres, contendo letras e números.
  bool validarSenhaSegura(String senha) {
    if (senha.length < 6) return false;
    final temLetra = RegExp(r'[a-zA-Z]').hasMatch(senha);
    final temNumero = RegExp(r'[0-9]').hasMatch(senha);
    return temLetra && temNumero;
  }

  /// Valida se a senha e a confirmação coincidem e atendem aos critérios de segurança.
  bool validarSenhas(String senha, String confirmarSenha) {
    return senha == confirmarSenha && validarSenhaSegura(senha);
  }

  /// Valida o formato básico de e-mail.
  bool validarEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());
  }

  /// Valida se o telefone possui ao menos 8 dígitos numéricos.
  bool validarTelefone(String telefone) {
    final apenasDigitos = telefone.replaceAll(RegExp(r'\D'), '');
    return apenasDigitos.length >= 8 && apenasDigitos.length <= 15;
  }

  /// Realiza o cadastro do usuário no Firebase Auth e grava seus dados no Firestore.
  Future<void> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
    required String telefone,
  }) async {
    final nomeLimpo = nome.trim();
    final emailLimpo = email.trim();
    final telefoneLimpo = telefone.trim();

    if (nomeLimpo.isEmpty || emailLimpo.isEmpty || telefoneLimpo.isEmpty || senha.isEmpty) {
      throw Exception('Por favor, preencha todos os campos obrigatórios, incluindo o telefone.');
    }

    if (!validarEmail(emailLimpo)) {
      throw Exception('Informe um endereço de e-mail válido.');
    }

    if (!validarTelefone(telefoneLimpo)) {
      throw Exception('Informe um número de telefone válido com DDD.');
    }

    if (!validarSenhaSegura(senha)) {
      throw Exception('A senha deve ter pelo menos 6 caracteres, contendo letras e números.');
    }

    UserCredential? userCredential;
    try {
      userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailLimpo,
        password: senha,
      );

      final User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(nomeLimpo);

        await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set({
          'uid': user.uid,
          'nome': nomeLimpo,
          'email': emailLimpo,
          'telefone': telefoneLimpo,
          'dataCadastro': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_traduzirErroAuth(e.code));
    } catch (e) {
      // Rollback no Firebase Auth caso a gravação no Firestore falhe
      try {
        await userCredential?.user?.delete();
      } catch (_) {}
      rethrow;
    }
  }

  String _traduzirErroAuth(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este e-mail já está sendo utilizado por outra conta.';
      case 'invalid-email':
        return 'O formato do e-mail informado é inválido.';
      case 'weak-password':
        return 'A senha escolhida é muito fraca.';
      case 'operation-not-allowed':
        return 'O cadastro por e-mail e senha não está habilitado.';
      case 'network-request-failed':
        return 'Erro de conexão. Verifique sua internet e tente novamente.';
      default:
        return 'Não foi possível concluir o cadastro ($code).';
    }
  }
}
