import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_routes.dart';
import '../core/dependencias.dart';
import '../controller/tela_inicial_controller.dart';

class TelaInicialView extends StatelessWidget {
  const TelaInicialView({super.key});

  Future<void> _sairDoAplicativo(BuildContext context, TelaInicialController controller) async {
    try {
      await controller.sair();
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao encerrar sessão: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TelaInicialController controller = g<TelaInicialController>();
    final user = FirebaseAuth.instance.currentUser;
    final Color vermelho = const Color(0xFFE7000B);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: vermelho,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Sobre o Projeto',
          icon: const Icon(Icons.info_outline, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.sobre),
        ),
        title: const Text(
          'Ribeirão Resolve',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _sairDoAplicativo(context, controller),
            icon: const Icon(Icons.logout, color: Colors.white, size: 18),
            label: const Text(
              'Sair',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Saudação dinâmica com o nome do usuário logado
                  if (user != null)
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('usuarios').doc(user.uid).snapshots(),
                      builder: (context, snapshot) {
                        final data = snapshot.data?.data() as Map<String, dynamic>?;
                        final nomeCompleto = (data?['nome'] as String?)?.trim() ?? user.displayName ?? '';
                        final primeiroNome = nomeCompleto.isNotEmpty
                            ? nomeCompleto.split(' ').first
                            : 'cidadão';
                        return Text(
                          'Olá, $primeiroNome!',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        );
                      },
                    )
                  else
                    const Text(
                      'Olá, cidadão!',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'Ajude a construir uma cidade melhor.',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),

                  // Painel de estatísticas das solicitações em tempo real (integrado ao TelaInicialController)
                  if (user != null)
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('solicitacoes')
                          .where('uid', isEqualTo: user.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        final docs = snapshot.data?.docs ?? [];
                        final stats = controller.calcularEstatisticas(docs);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 18),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatItem('Total', stats['total'].toString(), Colors.black87),
                              Container(width: 1, height: 28, color: Colors.grey.shade300),
                              _buildStatItem('Pendentes', stats['pendentes'].toString(), Colors.orange.shade800),
                              Container(width: 1, height: 28, color: Colors.grey.shade300),
                              _buildStatItem('Resolvidos', stats['resolvidos'].toString(), Colors.green.shade700),
                            ],
                          ),
                        );
                      },
                    ),

                  const Text(
                    'Viu algum problema na cidade?',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),

                  // Botão de Destaque: Registrar Problema
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.registrarProblema),
                    icon: const Icon(Icons.campaign, color: Colors.white, size: 22),
                    label: const Text(
                      'REGISTRAR PROBLEMA',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vermelho,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Acesse seus serviços',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),

                  // Card 1: Meu Perfil
                  _buildServiceCard(
                    context,
                    icon: Icons.person_outline,
                    title: 'Meu perfil',
                    subtitle: 'Consulte e atualize seus dados pessoais',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.perfil),
                  ),
                  const SizedBox(height: 10),

                  // Card 2: Enviar Sugestão
                  _buildServiceCard(
                    context,
                    icon: Icons.lightbulb_outline,
                    title: 'Enviar sugestão',
                    subtitle: 'Compartilhe suas ideias e acompanhe envios',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.sugestoes),
                  ),
                  const SizedBox(height: 10),

                  // Card 3: Minhas Solicitações
                  _buildServiceCard(
                    context,
                    icon: Icons.list_alt,
                    title: 'Minhas solicitações',
                    subtitle: 'Consulte os problemas registrados',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.minhasSolicitacoes),
                  ),
                  const SizedBox(height: 10),

                  // Card 4: Acompanhar Solicitação (Corrigido para AppRoutes.detalhesSolicitacao)
                  _buildServiceCard(
                    context,
                    icon: Icons.trending_up,
                    title: 'Acompanhar solicitação',
                    subtitle: 'Veja o andamento e os retornos da prefeitura',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.detalhesSolicitacao),
                  ),
                  const SizedBox(height: 10),

                  // Card 5: Sobre o Projeto (Tornando AppRoutes.sobre acessível pelo menu principal)
                  _buildServiceCard(
                    context,
                    icon: Icons.info_outline,
                    title: 'Sobre o projeto',
                    subtitle: 'Conheça a equipe e informações institucionais',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.sobre),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final Color vermelho = const Color(0xFFE7000B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: vermelho.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: vermelho, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}