import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../core/app_routes.dart';
import '../core/dependencias.dart';
import '../controller/solicitacao_controller.dart';

class DetalhesSolicitacoesView extends StatefulWidget {
  const DetalhesSolicitacoesView({super.key});

  @override
  State<DetalhesSolicitacoesView> createState() => _DetalhesSolicitacoesViewState();
}

class _DetalhesSolicitacoesViewState extends State<DetalhesSolicitacoesView> {
  final SolicitacaoController _controller = g<SolicitacaoController>();
  String? _docIdSelecionado;
  bool _argumentoLido = false;
  int _tentativaStream = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argumentoLido) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is String && arg.isNotEmpty) {
        _docIdSelecionado = arg;
      }
      _argumentoLido = true;
    }
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
          title: const Text('Detalhes da Solicitação', style: TextStyle(color: Colors.white)),
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
          'Detalhes da Solicitação',
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
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    children: [
                      Icon(Icons.show_chart, size: 32, color: vermelho),
                      const SizedBox(height: 6),
                      const Text(
                        'Acompanhamento da Solicitação',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Acompanhe as etapas e os retornos da prefeitura.',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
                                  'Erro ao carregar solicitação:\n${snapshot.error}',
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
                                Icon(Icons.assignment_late_outlined, size: 56, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                Text(
                                  'Você ainda não possui solicitações registradas para acompanhar.',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                  textAlign: TextAlign.center,
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

                      // Seleciona o documento correspondente ao ID ou o mais recente
                      QueryDocumentSnapshot docAtual = docs.first;
                      if (_docIdSelecionado != null) {
                        for (final d in docs) {
                          if (d.id == _docIdSelecionado) {
                            docAtual = d;
                            break;
                          }
                        }
                      }

                      final data = docAtual.data() as Map<String, dynamic>;
                      final categoria = data['categoria']?.toString() ?? 'Geral';
                      final status = data['status']?.toString() ?? 'Pendente';
                      final descricao = data['descricao']?.toString() ?? 'Sem descrição';
                      final endereco = data['endereco']?.toString() ?? 'Não informado';
                      final cep = data['cep']?.toString() ?? 'Não informado';

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

                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (docs.length > 1) ...[
                              DropdownButtonFormField<String>(
                                value: docAtual.id,
                                decoration: InputDecoration(
                                  labelText: 'Selecionar solicitação',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                items: docs.map((d) {
                                  final map = d.data() as Map<String, dynamic>;
                                  final cat = map['categoria'] ?? 'Solicitação';
                                  final desc = map['descricao'] ?? '';
                                  final resumo = desc.toString().length > 24
                                      ? '${desc.toString().substring(0, 24)}...'
                                      : desc.toString();
                                  return DropdownMenuItem<String>(
                                    value: d.id,
                                    child: Text(
                                      '$cat - $resumo',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (novoId) {
                                  if (novoId != null) {
                                    setState(() => _docIdSelecionado = novoId);
                                  }
                                },
                              ),
                              const SizedBox(height: 14),
                            ],
                            _buildTimelineCard(
                              docId: docAtual.id,
                              categoria: categoria,
                              status: status,
                              descricao: descricao,
                              endereco: endereco,
                              cep: cep,
                              dataFormatada: dataFormatada,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.sugestoes),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: vermelho,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Quer melhorar esse aplicativo?\nClique aqui e faça uma sugestão',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineCard({
    required String docId,
    required String categoria,
    required String status,
    required String descricao,
    required String endereco,
    required String cep,
    required String dataFormatada,
  }) {
    final statusLower = status.toLowerCase();
    final bool resolvido =
        statusLower == 'resolvido' || statusLower == 'concluído' || statusLower == 'concluido';
    final bool emAnalise =
        statusLower.contains('análise') || statusLower.contains('analise') || statusLower.contains('andamento');

    final Color corStatusAtual = resolvido
        ? Colors.green.shade700
        : (emAnalise ? Colors.blue.shade700 : Colors.orange.shade700);
    final IconData iconeStatusAtual = resolvido
        ? Icons.verified
        : (emAnalise ? Icons.sync : Icons.hourglass_empty);
    final String mensagemStatus = resolvido
        ? 'O problema relatado foi solucionado pela equipe responsável.'
        : (emAnalise
            ? 'Sua solicitação está em análise técnica pela secretaria.'
            : 'Sua solicitação foi enviada e aguarda acompanhamento.');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Histórico de acompanhamento',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          // Etapa 1: Solicitação registrada
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 14, color: Colors.white),
                  ),
                  Container(
                    width: 2,
                    height: 68,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Solicitação registrada',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Categoria: $categoria',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Local: $endereco (CEP: $cep)',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      'Registrado em: $dataFormatada',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Etapa 2: Status atual dinâmico
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: corStatusAtual,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconeStatusAtual, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: corStatusAtual,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      mensagemStatus,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Descrição informada: "$descricao"',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          const Text(
            'Atualizar situação da demanda:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatusChip(docId, 'Pendente', status == 'Pendente', Colors.orange.shade800),
              _buildStatusChip(docId, 'Em análise', status == 'Em análise', Colors.blue.shade700),
              _buildStatusChip(docId, 'Resolvido', status == 'Resolvido', Colors.green.shade700),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String docId, String label, bool selecionado, Color cor) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: selecionado ? Colors.white : cor,
        ),
      ),
      selected: selecionado,
      selectedColor: cor,
      backgroundColor: cor.withValues(alpha: 0.1),
      onSelected: (val) async {
        if (val && !selecionado) {
          await _controller.atualizarStatusSolicitacao(
            docId: docId,
            novoStatus: label,
          );
        }
      },
    );
  }
}
