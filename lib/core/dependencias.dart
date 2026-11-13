import 'package:get_it/get_it.dart';
import '../controller/cadastrar_usuario_controller.dart';
import '../controller/login_controller.dart';
import '../controller/perfil_controller.dart';
import '../controller/recuperar_senha_controller.dart';
import '../controller/sobre_controller.dart';
import '../controller/tela_inicial_controller.dart';
import '../controller/solicitacao_controller.dart';
import '../controller/sugestao_controller.dart';

final GetIt g = GetIt.instance;

void configurarDependencias() {
  if (!g.isRegistered<CadastrarUsuarioController>()) {
    g.registerLazySingleton(() => CadastrarUsuarioController());
  }
  if (!g.isRegistered<LoginController>()) {
    g.registerLazySingleton(() => LoginController());
  }
  if (!g.isRegistered<PerfilController>()) {
    g.registerLazySingleton(() => PerfilController());
  }
  if (!g.isRegistered<RecuperarSenhaController>()) {
    g.registerLazySingleton(() => RecuperarSenhaController());
  }
  if (!g.isRegistered<SobreController>()) {
    g.registerLazySingleton(() => SobreController());
  }
  if (!g.isRegistered<TelaInicialController>()) {
    g.registerLazySingleton(() => TelaInicialController());
  }
  if (!g.isRegistered<SolicitacaoController>()) {
    g.registerLazySingleton(() => SolicitacaoController());
  }
  if (!g.isRegistered<SugestaoController>()) {
    g.registerLazySingleton(() => SugestaoController());
  }
}
