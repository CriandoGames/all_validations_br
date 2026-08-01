import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

TextEditingValue _apply(TextInputFormatter f, String text) =>
    f.formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: text));

String _fmt(TextInputFormatter f, String text) => _apply(f, text).text;

void main() {
  // ── CestMask ────────────────────────────────────────────────────────────────
  group('CestMask', () {
    const mask = CestMask();

    test('vazio', () => expect(_fmt(mask, ''), ''));
    test('1 dígito', () => expect(_fmt(mask, '1'), '1'));
    test('2 dígitos', () => expect(_fmt(mask, '12'), '12'));
    test('3 dígitos', () => expect(_fmt(mask, '123'), '12.3'));
    test('5 dígitos', () => expect(_fmt(mask, '12345'), '12.345'));
    test('6 dígitos', () => expect(_fmt(mask, '123456'), '12.345.6'));
    test('completo 7', () => expect(_fmt(mask, '1234567'), '12.345.67'));
    test('trunca em 7', () => expect(_fmt(mask, '12345678'), '12.345.67'));
    test('já mascarado', () => expect(_fmt(mask, '12.345.67'), '12.345.67'));
    test('filtra letras', () => expect(_fmt(mask, '12AB345'), '12.345'));
  });

  // ── IofMask ─────────────────────────────────────────────────────────────────
  group('IofMask', () {
    const mask = IofMask();

    test('vazio', () => expect(_fmt(mask, ''), ''));
    test('1 dígito', () => expect(_fmt(mask, '1'), '1'));
    test('2 dígitos', () => expect(_fmt(mask, '12'), '1,2'));
    test('completo 7', () => expect(_fmt(mask, '1234567'), '1,234567'));
    test('trunca em 7', () => expect(_fmt(mask, '12345678'), '1,234567'));
    test('zero inicial', () => expect(_fmt(mask, '0038000'), '0,038000'));
    test('filtra letras', () => expect(_fmt(mask, 'abc'), ''));
    test('já mascarado', () => expect(_fmt(mask, '1,234567'), '1,234567'));
    test('dígito único zero', () => expect(_fmt(mask, '0'), '0'));
  });

  // ── NupMask ─────────────────────────────────────────────────────────────────
  group('NupMask', () {
    const mask = NupMask();

    test('vazio', () => expect(_fmt(mask, ''), ''));
    test('7 dígitos (sem traço)', () => expect(_fmt(mask, '1234567'), '1234567'));
    test('8 dígitos (com traço)', () =>
        expect(_fmt(mask, '12345678'), '1234567-8'));
    test('9 dígitos', () => expect(_fmt(mask, '123456789'), '1234567-89'));
    test('10 dígitos (ponto depois do 2º grupo)', () =>
        expect(_fmt(mask, '1234567890'), '1234567-89.0'));
    test('13 dígitos', () =>
        expect(_fmt(mask, '1234567890123'), '1234567-89.0123'));
    test('14 dígitos (ponto grupo 3→4)', () =>
        expect(_fmt(mask, '12345678901234'), '1234567-89.0123.4'));
    test('16 dígitos', () =>
        expect(_fmt(mask, '1234567890123456'), '1234567-89.0123.4.56'));
    test('completo 20', () =>
        expect(_fmt(mask, '12345678901234567890'), '1234567-89.0123.4.56.7890'));
    test('trunca em 20', () =>
        expect(_fmt(mask, '123456789012345678901'), '1234567-89.0123.4.56.7890'));
    test('já mascarado', () =>
        expect(_fmt(mask, '1234567-89.0123.4.56.7890'), '1234567-89.0123.4.56.7890'));
  });

  // ── CertNascimentoMask ──────────────────────────────────────────────────────
  group('CertNascimentoMask', () {
    const mask = CertNascimentoMask();

    test('vazio', () => expect(_fmt(mask, ''), ''));
    test('1 dígito', () => expect(_fmt(mask, '1'), '1'));
    test('6 dígitos (1º grupo sem espaço)', () =>
        expect(_fmt(mask, '000000'), '000000'));
    test('7 dígitos (espaço após 6)', () =>
        expect(_fmt(mask, '0000001'), '000000 1'));
    test('8 dígitos', () => expect(_fmt(mask, '00000011'), '000000 11'));
    test('10 dígitos', () => expect(_fmt(mask, '0000001122'), '000000 11 22'));
    test('14 dígitos', () =>
        expect(_fmt(mask, '00000011223333'), '000000 11 22 3333'));
    test('15 dígitos (grupo 5)', () =>
        expect(_fmt(mask, '000000112233334'), '000000 11 22 3333 4'));
    test('20 dígitos (grupo 6)', () =>
        expect(_fmt(mask, '00000011223333455555'), '000000 11 22 3333 4 55555'));
    test('23 dígitos (grupo 7)', () =>
        expect(_fmt(mask, '00000011223333455555666'), '000000 11 22 3333 4 55555 666'));
    test('30 dígitos (grupo 8)', () =>
        expect(_fmt(mask, '000000112233334555556667777777'),
            '000000 11 22 3333 4 55555 666 7777777'));
    test('completo 32', () =>
        expect(_fmt(mask, '00000011223333455555666777777788'),
            '000000 11 22 3333 4 55555 666 7777777 88'));
    test('trunca em 32', () =>
        expect(_fmt(mask, '000000112233334555556667777777788'),
            '000000 11 22 3333 4 55555 666 7777777 78'));
    test('já mascarado', () =>
        expect(_fmt(mask, '000000 11 22 3333 4 55555 666 7777777 88'),
            '000000 11 22 3333 4 55555 666 7777777 88'));
  });
}
