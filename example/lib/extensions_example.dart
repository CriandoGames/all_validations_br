// ignore_for_file: avoid_print
import 'package:all_validations_br/all_validations_br.dart';

/// Exemplos de uso de BoolExtension, StringExtension e ListExtension.
void main() {
  _boolExamples();
  _stringExamples();
  _listExamples();
}

// ── BoolExtension ──────────────────────────────────────────────────────────

void _boolExamples() {
  print('=== BoolExtension ===');

  bool? ativo = true;
  bool? inativo = false;
  bool? indefinido;

  print(ativo.isTrue); // true
  print(inativo.isTrue); // false
  print(indefinido.isTrue); // false — null seguro

  print(ativo.isFalse); // false
  print(inativo.isFalse); // true
  print(indefinido.isFalse); // false — null seguro

  if (ativo.isTrue) print('Usuário ativo');
  if (inativo.isFalse) print('Não está bloqueado');
  // null não entra em nenhum bloco — comportamento seguro
}

// ── StringExtension ────────────────────────────────────────────────────────

void _stringExamples() {
  print('\n=== StringExtension ===');

  String? nulo;
  String? vazio = '';
  String? espacos = '   ';
  String? comConteudo = '  Carlos  ';

  // isNullOrEmpty — espaços NÃO são considerados vazios
  print(nulo.isNullOrEmpty); // true
  print(vazio.isNullOrEmpty); // true
  print(espacos.isNullOrEmpty); // false
  print(comConteudo.isNullOrEmpty); // false

  // isNotNullOrEmpty
  print(comConteudo.isNotNullOrEmpty); // true
  print(nulo.isNotNullOrEmpty); // false

  // isNullOrEmptyWithSpace — espaços SÃO considerados vazios
  print(nulo.isNullOrEmptyWithSpace); // true
  print(vazio.isNullOrEmptyWithSpace); // true
  print(espacos.isNullOrEmptyWithSpace); // true
  print(comConteudo.isNullOrEmptyWithSpace); // false — tem conteúdo real

  // isNotNullOrEmptyWithSpace
  print(comConteudo.isNotNullOrEmptyWithSpace); // true

  // truncate
  print('Flutter é incrível'.truncate(7)); // Flutter...
  print('Dart'.truncate(10)); // Dart      (não altera)
  print(nulo.truncate(5)); // null      (null seguro)

  // Uso em formulário
  String? nomeCampo = '   ';
  if (nomeCampo.isNullOrEmptyWithSpace) {
    print('Nome é obrigatório');
  }

  // Uso em UI
  const descricao = 'Produto com descrição muito longa para caber na tela';
  print(descricao.truncate(20)); // 'Produto com descrição...'
}

// ── ListExtension ──────────────────────────────────────────────────────────

void _listExamples() {
  print('\n=== ListExtension ===');

  List<String>? nula;
  List<String>? vazia = [];
  List<String>? comItens = ['CPF inválido', 'E-mail obrigatório'];

  print(nula.isNullOrEmpty); // true
  print(vazia.isNullOrEmpty); // true
  print(comItens.isNullOrEmpty); // false

  print(nula.isNotNullOrEmpty); // false
  print(comItens.isNotNullOrEmpty); // true

  // Uso com notifications de Contract
  List<String>? erros = buscarErros();
  if (erros.isNotNullOrEmpty) {
    print('Há ${erros!.length} erro(s): ${erros.join(', ')}');
  }
}

List<String>? buscarErros() => ['Campo obrigatório'];
