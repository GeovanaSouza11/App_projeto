import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cadastrar_usuario_controller.dart';

class PerfilController extends ChangeNotifier {
  final CadastrarUsuarioController _cadastroHelper = CadastrarUsuarioController();

  bool validarSenhaSegura(String senha) {
    return _cadastroHelper.validarSenhaSegura(senha);
  }

  /// Mantido para compatibilidade direta com chamadas de cadastro existentes.
  Future<void> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
    required String telefone,
  }) async {
    await _cadastroHelper.cadastrarUsuario(
      nome: nome,
      email: email,
      senha: senha,
      telefone: telefone,
    );
  }

  /// Carrega os dados completos do perfil do usuário autenticado (nome, email e telefone).
  Future<Map<String, String>> carregarDadosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado. Faça login novamente.');
    }

    String nome = user.displayName ?? '';
    String email = user.email ?? '';
    String telefone = '';

    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      nome = (data['nome'] as String?)?.trim() ?? nome;
      email = (data['email'] as String?)?.trim() ?? email;
      final telSalvo = (data['telefone'] as String?)?.trim() ?? '';
      telefone = (telSalvo == 'Não informado') ? '' : telSalvo;
    }

    return {
      'nome': nome,
      'email': email,
      'telefone': telefone,
    };
  }

  /// Atualiza o nome e o telefone do usuário no Firestore e no Firebase Auth.
  Future<void> salvarAlteracoes({
    required String nome,
    required String telefone,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado. Faça login novamente.');
    }

    final nomeLimpo = nome.trim();
    final telefoneLimpo = telefone.trim();

    if (nomeLimpo.isEmpty) {
      throw Exception('O nome do usuário não pode estar vazio.');
    }

    if (telefoneLimpo.isEmpty || !_cadastroHelper.validarTelefone(telefoneLimpo)) {
      throw Exception('Informe um telefone válido com DDD.');
    }

    await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set({
      'uid': user.uid,
      'nome': nomeLimpo,
      'email': user.email ?? '',
      'telefone': telefoneLimpo,
      'dataAtualizacao': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await user.updateDisplayName(nomeLimpo);
    notifyListeners();
  }
}
