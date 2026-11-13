import 'package:flutter/material.dart';
import '../core/app_routes.dart';
import '../core/dependencias.dart';
import '../controller/login_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController _loginController = g<LoginController>();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  String _limparMensagemErro(Object e) {
    return e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
  }

  Future<void> _fazerLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      await _loginController.realizarLogin(
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.telaInicial);
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6)),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: AnimatedBuilder(
                    animation: _loginController,
                    builder: (context, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: vermelho.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.location_city, size: 56, color: vermelho),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Ribeirão Resolve',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Faça login para gerenciar suas solicitações',
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            'E-mail',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onChanged: _loginController.atualizarEmail,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600], size: 20),
                              hintText: 'seu@email.com',
                              hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty ? 'Informe seu e-mail.' : null,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Senha',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _senhaController,
                            obscureText: !_loginController.mostrarSenha,
                            textInputAction: TextInputAction.done,
                            onChanged: _loginController.atualizarSenha,
                            onFieldSubmitted: (_) => _fazerLogin(),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600], size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _loginController.mostrarSenha ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                onPressed: _loginController.alternarVisibilidadeSenha,
                              ),
                              hintText: 'Sua senha',
                              hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            validator: (value) =>
                                value == null || value.isEmpty ? 'Informe sua senha.' : null,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.recuperarSenha);
                              },
                              child: Text(
                                'Esqueceu a senha?',
                                style: TextStyle(color: vermelho, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 50,
                            child: _carregando
                                ? const Center(child: CircularProgressIndicator())
                                : ElevatedButton(
                                    onPressed: _fazerLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: vermelho,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Entrar',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Não tem uma conta?',
                                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, AppRoutes.cadastrarUsuario);
                                },
                                child: Text(
                                  'Cadastre-se',
                                  style: TextStyle(color: vermelho, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Center(
                            child: TextButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.sobre);
                              },
                              icon: Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                              label: Text(
                                'Sobre o projeto',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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