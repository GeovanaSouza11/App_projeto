import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../core/app_routes.dart';
import '../core/dependencias.dart';
import '../controller/solicitacao_controller.dart';

class MinhasSolicitacoesView extends StatefulWidget {
  const MinhasSolicitacoesView({super.key});

  @override
  State<MinhasSolicitacoesView> createState() => _MinhasSolicitacoesViewState();
}

class _MinhasSolicitacoesViewState extends State<MinhasSolicitacoesView> {
  final SolicitacaoController _controller = g<SolicitacaoController>();
  int _tentativaStream = 0;

  Color _corPorStatus(String status) {
    final s = status.toLowerCase();
    if (s == 'resolvido' || s == 'concluído' || s == 'concluido') {
      return Colors.green.shade700;
    }
    if (s.contains('análise') || s.contains('analise') || s.contains('andamento')) {
      return Colors.blue.shade700;
    }
    return Colors.orange.shade800;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final Color vermelho = const Color(0xFFE7000B);

    if (user == null) {
      return Scaffold(
        backgroundColor: vermelho,
        appBar: AppBar(
          backgroundColor: vermelho,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Minhas Solicitações', style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Usuário não autenticado.',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                child: const Text('Ir para o Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: vermelho,
      appBar: AppBar(
        backgroundColor: vermelho,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Minhas Solicitações',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.telaInicial),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 550),
            width: double.infinity,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Toque em uma solicitação para acompanhar os detalhes e o andamento.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    key: ValueKey(_tentativaStream),
                    stream: FirebaseFirestore.instance
                        .collection('solicitacoes')
                        .where('uid', isEqualTo: user.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Erro ao carregar solicitações em tempo real:\n${snapshot.error}',
                                  style: const TextStyle(color: Colors.red, fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 14),
                                ElevatedButton.icon(
                                  onPressed: () => setState(() => _tentativaStream++),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: vermelho,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Tentar novamente'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final rawDocs = snapshot.data?.docs ?? [];
                      final docs = _controller.ordenarPorDataDesc(rawDocs);

                      if (docs.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.folder_open, size: 60, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                Text(
                                  'Nenhuma solicitação encontrada.',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      Navigator.pushNamed(context, AppRoutes.registrarProblema),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: vermelho,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Registrar Problema'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;

                          final categoria = data['categoria'] ?? 'Geral';
                          final status = data['status'] ?? 'Pendente';
                          final descricao = data['descricao'] ?? 'Sem descrição';
                          final endereco = data['endereco'] ?? 'Não informado';
                          final cep = data['cep'] ?? 'Não informado';
                          final anexoFoto = data['anexoFoto'] as String?;
                          final corStatus = _corPorStatus(status);

                          String dataFormatada = 'Data recente';
                          final rawData = data['dataCadastro'] ?? data['data'];
                          if (rawData is Timestamp) {
                            dataFormatada = DateFormat('dd/MM/yyyy HH:mm').format(rawData.toDate());
                          } else if (data['dataCriacaoIso'] is String) {
                            final parsed = DateTime.tryParse(data['dataCriacaoIso']);
                            if (parsed != null) {
                              dataFormatada = DateFormat('dd/MM/yyyy HH:mm').format(parsed);
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.detalhesSolicitacao,
                                  arguments: doc.id,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade200),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            categoria,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: corStatus.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            status,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: corStatus,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 24, thickness: 1),
                                    _buildInfoRow(
                                      icon: Icons.description_outlined,
                                      label: 'Descrição',
                                      value: descricao,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInfoRow(
                                      icon: Icons.location_on_outlined,
                                      label: 'Endereço',
                                      value: endereco,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInfoRow(
                                      icon: Icons.pin_drop_outlined,
                                      label: 'CEP',
                                      value: cep,
                                    ),
                                    if (anexoFoto != null && anexoFoto.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      _buildInfoRow(
                                        icon: Icons.photo_camera_outlined,
                                        label: 'Foto anexada',
                                        value: anexoFoto,
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    _buildInfoRow(
                                      icon: Icons.calendar_today_outlined,
                                      label: 'Data do registro',
                                      value: dataFormatada,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Acompanhar solicitação',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: vermelho,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(Icons.arrow_forward_ios, size: 12, color: vermelho),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFFE7000B)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
