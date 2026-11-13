import 'package:flutter_test/flutter_test.dart';
import 'package:appprojeto/core/dependencias.dart';
import 'package:appprojeto/controller/cadastrar_usuario_controller.dart';
import 'package:appprojeto/controller/login_controller.dart';
import 'package:appprojeto/controller/perfil_controller.dart';
import 'package:appprojeto/controller/recuperar_senha_controller.dart';
import 'package:appprojeto/controller/sobre_controller.dart';
import 'package:appprojeto/controller/tela_inicial_controller.dart';
import 'package:appprojeto/controller/solicitacao_controller.dart';
import 'package:appprojeto/controller/sugestao_controller.dart';

void main() {
  setUpAll(() {
    configurarDependencias();
  });

  group('Injeção de Dependências (GetIt)', () {
    test('Todos os controllers devem estar registrados no GetIt', () {
      expect(g.isRegistered<CadastrarUsuarioController>(), isTrue);
      expect(g.isRegistered<LoginController>(), isTrue);
      expect(g.isRegistered<PerfilController>(), isTrue);
      expect(g.isRegistered<RecuperarSenhaController>(), isTrue);
      expect(g.isRegistered<SobreController>(), isTrue);
      expect(g.isRegistered<TelaInicialController>(), isTrue);
      expect(g.isRegistered<SolicitacaoController>(), isTrue);
      expect(g.isRegistered<SugestaoController>(), isTrue);
    });
  });

  group('Regras de Negócio - Cadastro e Perfil', () {
    final cadastroCtrl = g<CadastrarUsuarioController>();
    final perfilCtrl = g<PerfilController>();

    test('Validação de senha segura consistente entre CadastrarUsuarioController e PerfilController', () {
      expect(cadastroCtrl.validarSenhaSegura('12345'), isFalse);
      expect(cadastroCtrl.validarSenhaSegura('123456'), isFalse);
      expect(cadastroCtrl.validarSenhaSegura('abcdef'), isFalse);
      expect(cadastroCtrl.validarSenhaSegura('Abc123'), isTrue);

      expect(perfilCtrl.validarSenhaSegura('123456'), equals(cadastroCtrl.validarSenhaSegura('123456')));
      expect(perfilCtrl.validarSenhaSegura('Abc123'), equals(cadastroCtrl.validarSenhaSegura('Abc123')));
    });

    test('Validação de confirmação de senha', () {
      expect(cadastroCtrl.validarSenhas('Abc123', 'Abc124'), isFalse);
      expect(cadastroCtrl.validarSenhas('123456', '123456'), isFalse);
      expect(cadastroCtrl.validarSenhas('Abc123', 'Abc123'), isTrue);
    });

    test('Validação de e-mail e telefone', () {
      expect(cadastroCtrl.validarEmail('usuario@fatec.sp.gov.br'), isTrue);
      expect(cadastroCtrl.validarEmail('email_invalido'), isFalse);

      expect(cadastroCtrl.validarTelefone('(16) 99999-9999'), isTrue);
      expect(cadastroCtrl.validarTelefone('123'), isFalse);
    });
  });

  group('Regras de Negócio - Solicitações e CEP', () {
    final solicitacaoCtrl = g<SolicitacaoController>();

    test('Validação e formatação de CEP', () {
      expect(solicitacaoCtrl.validarCep('14000-000'), isTrue);
      expect(solicitacaoCtrl.validarCep('14000000'), isTrue);
      expect(solicitacaoCtrl.validarCep('12345'), isFalse);
      expect(solicitacaoCtrl.validarCep('abcdefgh'), isFalse);
      expect(solicitacaoCtrl.formatarCep('14000000'), equals('14000-000'));
    });
  });

  group('Controle de Estado - Login e Tela Inicial', () {
    test('LoginController atualiza estado de campos e visibilidade de senha', () {
      final loginCtrl = LoginController();
      expect(loginCtrl.camposPreenchidos, isFalse);

      loginCtrl.atualizarEmail('cidadao@ribeirao.sp.gov.br');
      loginCtrl.atualizarSenha('Senha123');
      expect(loginCtrl.camposPreenchidos, isTrue);

      expect(loginCtrl.mostrarSenha, isFalse);
      loginCtrl.alternarVisibilidadeSenha();
      expect(loginCtrl.mostrarSenha, isTrue);
    });

    test('TelaInicialController atualiza contadores de solicitações', () {
      final homeCtrl = TelaInicialController();
      homeCtrl.atualizarEstatisticas(total: 5, pendentes: 3, resolvidos: 2);
      expect(homeCtrl.total, equals('5'));
      expect(homeCtrl.pendentes, equals('3'));
      expect(homeCtrl.resolvidos, equals('2'));
    });
  });
}
