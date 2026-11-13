import 'package:flutter/material.dart';

class SobreController extends ChangeNotifier {
  final String nomeApp = 'Ribeirão Resolve';
  final String slogan = 'Juntos por uma cidade melhor';
  final String objetivo =
      'O Ribeirão Resolve é um sistema mobile de ouvidoria urbana que busca facilitar o registro '
      'de problemas na cidade de Ribeirão Preto. A proposta é facilitar a comunicação de problemas '
      'urbanos pelos cidadãos e permitir o acompanhamento das solicitações registradas no aplicativo.';

  final List<String> equipe = const [
    'Gabriela Rampazzo Galoni',
    'Geovana Souza',
  ];

  final String instituicao = 'Fatec Ribeirão Preto';
  final String curso = 'Análise e Desenvolvimento de Sistemas (ADS)';
  final String disciplina = 'Programação para Dispositivos Móveis';
  final String professor = 'Rodrigo de Oliveira Plotze';
  final String versao = '1.0.0';
}
