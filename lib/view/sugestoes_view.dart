import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../core/app_routes.dart';
import '../core/dependencias.dart';
import '../controller/sugestao_controller.dart';

class SugestoesView extends StatefulWidget {
  const SugestoesView({super.key});

  @override
  State<SugestoesView> createState() => _SugestoesViewState();
}

class _SugestoesViewState extends State<SugestoesView> {
  final SugestaoController _controller = g<SugestaoController>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  late String _categoriaSelecionada;
  bool _enviando = false;
  int _tentativaStream = 0;

  final Color vermelho = const Color(0xFFE7000B);

  @override
  void initState() {
    super.initState();
    _categoriaSelecionada = _controller.categoriasSugestao.first;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  String _limparMensagemErro(Object e) {
    return e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
  }

  Future<void> _enviarSugestao() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enviando = true);

    try {
      await _controller.enviarSugestao(
        titulo: _tituloController.text,
        descricao: _descricaoController.text,
        categoria: _categoriaSelecionada,
      );

      _tituloController.clear();
      _descricaoController.clear();
      FocusScope.of(context).unfocus();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sugestão enviada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_limparMensagemErro(e)),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: vermelho,
        appBar: AppBar(
          backgroundColor: vermelho,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Sugestões', style: TextStyle(color: Colors.white)),
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
          'Sugestões',
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Formulário para envio de nova sugestão (RF003)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb_outline, color: vermelho, size: 22),
                              const SizedBox(width: 8),
                              const Text(
                                'Enviar nova sugestão',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Compartilhe suas ideias para melhorar o aplicativo e a cidade.',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            value: _categoriaSelecionada,
                            decoration: InputDecoration(
                              labelText: 'Área da sugestão',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            items: _controller.categoriasSugestao.map((cat) {
                              return DropdownMenuItem<String>(
                                value: cat,
                                child: Text(cat, style: const TextStyle(fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (novaCat) {
                              if (novaCat != null) {
                                setState(() => _categoriaSelecionada = novaCat);
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _tituloController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Título / Assunto',
                              hintText: 'Ex.: Melhoria na iluminação ou no app',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            validator: (value) => value == null || value.trim().isEmpty
                                ? 'Informe um título para a sugestão.'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descricaoController,
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: 'Descrição da sugestão',
                              hintText: 'Descreva sua ideia com detalhes...',
                              filled: true,
                              fillColor: Colors.white,
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            validator: (value) => value == null || value.trim().isEmpty
                                ? 'Descreva a sua sugestão.'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 46,
                            child: ElevatedButton.icon(
                              onPressed: _enviando ? null : _enviarSugestao,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: vermelho,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                              icon: _enviando
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Icon(Icons.send, size: 18),
                              label: Text(
                                _enviando ? 'Enviando...' : 'Enviar Sugestão',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Minhas Sugestões Enviadas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Acompanhe as sugestões enviadas por você em tempo real.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  // Recuperação em tempo real com StreamBuilder e ListView (RF004)
                  StreamBuilder<QuerySnapshot>(
                    key: ValueKey(_tentativaStream),
                    stream: _controller.obterStreamSugestoes(user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Text(
                                'Erro ao carregar sugestões em tempo real:\n${snapshot.error}',
                                style: const TextStyle(color: Colors.red, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
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
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final rawDocs = snapshot.data?.docs ?? [];
                      final docs = _controller.ordenarPorDataDesc(rawDocs);

                      if (docs.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lightbulb_outline, size: 52, color: Colors.grey[400]),
                              const SizedBox(height: 10),
                              Text(
                                'Nenhuma sugestão enviada ainda.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;

                          final titulo = data['titulo'] ?? 'Sugestão';
                          final descricao = data['descricao'] ?? 'Sem descrição';
                          final categoria = data['categoria'] ?? 'Geral';
                          final status = data['status'] ?? 'Recebida';

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

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
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
                                        titulo,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Excluir sugestão',
                                      visualDensity: VisualDensity.compact,
                                      icon: Icon(Icons.delete_outline, size: 20, color: Colors.grey[600]),
                                      onPressed: () => _controller.excluirSugestao(doc.id),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Área: $categoria',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const Divider(height: 16, thickness: 1),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.comment_outlined,
                                      size: 18,
                                      color: Color(0xFFE7000B),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        descricao,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 16,
                                      color: Color(0xFFE7000B),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Enviado em: $dataFormatada',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
