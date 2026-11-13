import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../core/app_routes.dart';
import '../core/dependencias.dart';
import '../controller/solicitacao_controller.dart';

class RegistrarProblemaView extends StatefulWidget {
  const RegistrarProblemaView({super.key});

  @override
  State<RegistrarProblemaView> createState() => _RegistrarProblemaViewState();
}

class _RegistrarProblemaViewState extends State<RegistrarProblemaView> {
  final SolicitacaoController _controller = g<SolicitacaoController>();
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _cepController = TextEditingController();

  late String _categoriaSelecionada;
  String? _nomeFotoSelecionada;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _categoriaSelecionada = _controller.categorias.first;
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _enderecoController.dispose();
    _cepController.dispose();
    super.dispose();
  }

  String _limparMensagemErro(Object e) {
    return e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
  }

  Future<void> _selecionarFoto() async {
    try {
      final picker = ImagePicker();
      final XFile? imagem = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        imageQuality: 80,
      );
      if (imagem != null && mounted) {
        setState(() {
          _nomeFotoSelecionada = imagem.name;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível selecionar a imagem: $e')),
      );
    }
  }

  Future<void> _salvarSolicitacao() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: Usuário não autenticado. Faça login novamente.')),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    setState(() => _carregando = true);

    try {
      await _controller.registrarSolicitacao(
        categoria: _categoriaSelecionada,
        descricao: _descricaoController.text,
        endereco: _enderecoController.text,
        cep: _cepController.text,
        nomeFoto: _nomeFotoSelecionada,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitação registrada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, AppRoutes.minhasSolicitacoes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_limparMensagemErro(e)),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color vermelho = const Color(0xFFE7000B);

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
          'Registrar Problema',
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Preencha os detalhes do problema encontrado na cidade.',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _categoriaSelecionada,
                        decoration: InputDecoration(
                          labelText: 'Categoria',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        items: _controller.categorias.map((String categoria) {
                          return DropdownMenuItem<String>(
                            value: categoria,
                            child: Text(categoria),
                          );
                        }).toList(),
                        onChanged: (String? novaCategoria) {
                          if (novaCategoria != null) {
                            setState(() => _categoriaSelecionada = novaCategoria);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descricaoController,
                        maxLines: 3,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Descrição do problema',
                          hintText: 'Descreva o que está acontecendo...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, insira uma descrição.';
                          }
                          if (value.trim().length < 5) {
                            return 'Descreva o problema com pelo menos 5 caracteres.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _enderecoController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Endereço',
                          hintText: 'Rua, número e bairro',
                          prefixIcon: Icon(Icons.location_on_outlined, color: vermelho),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Por favor, informe o endereço.' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cepController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'CEP',
                          hintText: '14000-000',
                          prefixIcon: Icon(Icons.pin_drop_outlined, color: vermelho),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, informe o CEP.';
                          }
                          if (!_controller.validarCep(value)) {
                            return 'Informe um CEP válido com 8 dígitos (ex.: 14000-000).';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _selecionarFoto,
                        icon: Icon(
                          _nomeFotoSelecionada != null ? Icons.check_circle : Icons.add_a_photo_outlined,
                          color: _nomeFotoSelecionada != null ? Colors.green : vermelho,
                        ),
                        label: Text(
                          _nomeFotoSelecionada != null
                              ? 'Foto anexada: $_nomeFotoSelecionada'
                              : 'Anexar foto do local (opcional)',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _nomeFotoSelecionada != null ? Colors.green.shade700 : Colors.black87,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _carregando ? null : _salvarSolicitacao,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: vermelho,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: _carregando
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : const Text(
                                  'Enviar Solicitação',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}