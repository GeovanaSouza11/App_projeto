import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SugestaoController extends ChangeNotifier {
  final List<String> categoriasSugestao = const [
    'Melhoria no Aplicativo',
    'Serviços Urbanos',
    'Atendimento ao Cidadão',
    'Acessibilidade',
    'Outros',
  ];

  /// Grava uma nova sugestão no Firestore com mais de 5 campos distintos (atendendo RF003).
  Future<void> enviarSugestao({
    required String titulo,
    required String descricao,
    String categoria = 'Melhoria no Aplicativo',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado. Faça login novamente.');
    }

    final tituloLimpo = titulo.trim();
    final descricaoLimpa = descricao.trim();

    if (tituloLimpo.isEmpty || descricaoLimpa.isEmpty) {
      throw Exception('Preencha o título e a descrição da sua sugestão.');
    }

    await FirebaseFirestore.instance.collection('sugestoes').add({
      'uid': user.uid,
      'usuarioId': user.uid,
      'emailUsuario': user.email ?? 'Não informado',
      'categoria': categoria,
      'titulo': tituloLimpo,
      'descricao': descricaoLimpa,
      'status': 'Recebida',
      'dataCadastro': FieldValue.serverTimestamp(),
      'data': FieldValue.serverTimestamp(),
      'dataCriacaoIso': DateTime.now().toIso8601String(),
    });

    notifyListeners();
  }

  /// Exclui uma sugestão enviada pelo usuário no Firestore.
  Future<void> excluirSugestao(String docId) async {
    await FirebaseFirestore.instance.collection('sugestoes').doc(docId).delete();
    notifyListeners();
  }

  /// Retorna o stream em tempo real das sugestões do usuário autenticado usando a chave padronizada 'uid'.
  Stream<QuerySnapshot> obterStreamSugestoes(String uid) {
    return FirebaseFirestore.instance
        .collection('sugestoes')
        .where('uid', isEqualTo: uid)
        .snapshots();
  }

  /// Ordena as sugestões da mais recente para a mais antiga em memória (evita necessidade de índice composto).
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
