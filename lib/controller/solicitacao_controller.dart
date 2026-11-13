import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SolicitacaoController extends ChangeNotifier {
  final List<String> categorias = const [
    'Trânsito e Mobilidade',
    'Iluminação Pública',
    'Buraco na Rua',
    'Limpeza Urbana',
    'Outros',
  ];

  /// Valida se o CEP possui exatamente 8 dígitos numéricos (com ou sem hífen).
  bool validarCep(String cep) {
    return RegExp(r'^\d{5}-?\d{3}$').hasMatch(cep.trim());
  }

  /// Formata o CEP no padrão 00000-000.
  String formatarCep(String cep) {
    final digitos = cep.replaceAll(RegExp(r'\D'), '');
    if (digitos.length == 8) {
      return '${digitos.substring(0, 5)}-${digitos.substring(5)}';
    }
    return cep.trim();
  }

  /// Registra uma nova solicitação de problema urbano no Firestore.
  Future<String> registrarSolicitacao({
    required String categoria,
    required String descricao,
    required String endereco,
    required String cep,
    String? nomeFoto,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado. Faça login novamente.');
    }

    final descricaoLimpa = descricao.trim();
    final enderecoLimpo = endereco.trim();
    final cepLimpo = cep.trim();

    if (descricaoLimpa.isEmpty) {
      throw Exception('Por favor, insira uma descrição para o problema.');
    }

    if (enderecoLimpo.isEmpty) {
      throw Exception('Por favor, informe o endereço da ocorrência.');
    }

    if (!validarCep(cepLimpo)) {
      throw Exception('Informe um CEP válido com 8 dígitos (ex.: 14000-000).');
    }

    final docRef = await FirebaseFirestore.instance.collection('solicitacoes').add({
      'uid': user.uid,
      'emailUsuario': user.email ?? 'Não informado',
      'categoria': categoria,
      'descricao': descricaoLimpa,
      'endereco': enderecoLimpo,
      'cep': formatarCep(cepLimpo),
      'status': 'Pendente',
      if (nomeFoto != null && nomeFoto.isNotEmpty) 'anexoFoto': nomeFoto,
      'dataCadastro': FieldValue.serverTimestamp(),
      'dataCriacaoIso': DateTime.now().toIso8601String(),
    });

    notifyListeners();
    return docRef.id;
  }

  /// Atualiza o status de uma solicitação existente no Firestore.
  Future<void> atualizarStatusSolicitacao({
    required String docId,
    required String novoStatus,
  }) async {
    await FirebaseFirestore.instance.collection('solicitacoes').doc(docId).update({
      'status': novoStatus,
      'dataAtualizacao': FieldValue.serverTimestamp(),
    });
    notifyListeners();
  }

  /// Exclui uma solicitação do usuário.
  Future<void> excluirSolicitacao(String docId) async {
    await FirebaseFirestore.instance.collection('solicitacoes').doc(docId).delete();
    notifyListeners();
  }

  /// Ordena os documentos da mais recente para a mais antiga sem exigir índice composto no Firestore.
  List<QueryDocumentSnapshot> ordenarPorDataDesc(List<QueryDocumentSnapshot> docs) {
    final lista = List<QueryDocumentSnapshot>.from(docs);
    lista.sort((a, b) {
      final dataA = _extrairData(a.data() as Map<String, dynamic>);
      final dataB = _extrairData(b.data() as Map<String, dynamic>);
      return dataB.compareTo(dataA);
    });
    return lista;
  }

  DateTime _extrairData(Map<String, dynamic> map) {
    final raw = map['dataCadastro'] ?? map['data'];
    if (raw is Timestamp) {
      return raw.toDate();
    }
    final iso = map['dataCriacaoIso'];
    if (iso is String) {
      final parsed = DateTime.tryParse(iso);
      if (parsed != null) return parsed;
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
