import 'package:flutter/material.dart';
import '../core/dependencias.dart';
import '../controller/sobre_controller.dart';

class SobreView extends StatelessWidget {
  const SobreView({super.key});

  static const Color vermelho = Color(0xFFE7000B);
  static const Color cinza = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    final SobreController controller = g<SobreController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: vermelho,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Sobre o Projeto',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            size: 24,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: vermelho.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_city,
                        color: vermelho,
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      controller.nomeApp,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: cinza,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      controller.slogan,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: cinza,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _titulo('Objetivo do Aplicativo'),
                  const SizedBox(height: 6),
                  Text(
                    controller.objetivo,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: cinza,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  _titulo('Equipe de Desenvolvimento'),
                  const SizedBox(height: 8),
                  ...controller.equipe.map(
                    (integrante) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _membro(integrante),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  _titulo('Informações Institucionais'),
                  const SizedBox(height: 10),
                  _informacao(Icons.school_outlined, 'Instituição', controller.instituicao),
                  const SizedBox(height: 10),
                  _informacao(Icons.menu_book_outlined, 'Curso', controller.curso),
                  const SizedBox(height: 10),
                  _informacao(Icons.book_outlined, 'Disciplina', controller.disciplina),
                  const SizedBox(height: 10),
                  _informacao(Icons.person_outline, 'Professor', controller.professor),
                  const SizedBox(height: 10),
                  _informacao(Icons.info_outline, 'Versão do aplicativo', controller.versao),
                  const SizedBox(height: 10),
                  const Divider(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _titulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: cinza,
      ),
    );
  }

  static Widget _membro(String nome) {
    return Row(
      children: [
        const Icon(
          Icons.person_outline,
          color: vermelho,
          size: 22,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            nome,
            style: const TextStyle(
              fontSize: 15,
              color: cinza,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _informacao(
    IconData icone,
    String titulo,
    String descricao,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icone,
          color: vermelho,
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                descricao,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.25,
                  fontWeight: FontWeight.w500,
                  color: cinza,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
