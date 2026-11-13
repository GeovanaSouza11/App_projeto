import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaInicialController extends ChangeNotifier {
  int? _total;
  int? _pendentes;
  int? _resolvidos;

  String get total => _total?.toString() ?? '0';
  String get pendentes => _pendentes?.toString() ?? '0';
  String get resolvidos => _resolvidos?.toString() ?? '0';

  void atualizarEstatisticas({
    required int total,
    required int pendentes,
    required int resolvidos,
  }) {
    _total = total;
    _pendentes = pendentes;
    _resolvidos = resolvidos;
    notifyListeners();
  }

  /// Calcula as estatísticas (total, pendentes e resolvidos) a partir dos documentos do Firestore.
  Map<String, int> calcularEstatisticas(List<QueryDocumentSnapshot> docs) {
    final int totalCount = docs.length;
    int pendentesCount = 0;
    int resolvidosCount = 0;

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = (data['status']?.toString() ?? 'Pendente').toLowerCase();
      if (status == 'resolvido' || status == 'concluído' || status == 'concluido') {
        resolvidosCount++;
      } else {
        pendentesCount++;
      }
    }

    _total = totalCount;
    _pendentes = pendentesCount;
    _resolvidos = resolvidosCount;

    return {
      'total': totalCount,
      'pendentes': pendentesCount,
      'resolvidos': resolvidosCount,
    };
  }

  Future<void> sair() async {
    await FirebaseAuth.instance.signOut();
  }
}
