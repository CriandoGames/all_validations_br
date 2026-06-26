import 'dart:convert';

import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'All Validations BR — Exemplos',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ExamplesPage(),
    );
  }
}

class ExamplesPage extends StatefulWidget {
  const ExamplesPage({Key? key}) : super(key: key);

  @override
  State<ExamplesPage> createState() => _ExamplesPageState();
}

class _ExamplesPageState extends State<ExamplesPage> {
  // ── CryptUtil: estado da demo de criptografia ──────────────────────────────
  late final _cryptKey = CryptUtil.generateKey();
  String _encryptedBase64 = '';
  String _decryptedText = '';
  String _cryptError = '';

  void _runCryptDemo() {
    setState(() {
      _cryptError = '';
      try {
        const plaintext = 'Dados sensíveis do usuário 🔒';

        // 1. Criptografa e serializa como base64
        _encryptedBase64 = CryptUtil.encryptToBase64(plaintext, key: _cryptKey);

        // 2. Decriptografa a partir do base64
        _decryptedText = CryptUtil.decryptFromBase64(_encryptedBase64);
      } on CryptException catch (e) {
        _cryptError = e.toString();
      }
    });
  }

  void _runTamperingDemo() {
    setState(() {
      _cryptError = '';
      _decryptedText = '';
      try {
        final payload = CryptUtil.encryptText('segredo', key: _cryptKey);

        // Adultera o primeiro byte do ciphertext
        final tamperedBytes = Uint8List.fromList(payload.ciphertext);
        tamperedBytes[0] ^= 0xFF;
        final tampered = EncryptedPayload(
          ciphertext: Uint8List.fromList(
              List<int>.from(payload.ciphertext)..[0] ^= 0xFF),
          key: payload.key,
          tag: payload.tag,
          nonce: payload.nonce,
          aad: payload.aad,
        );

        CryptUtil.decryptText(tampered); // deve lançar CryptException
      } on CryptException catch (e) {
        _cryptError = '✅ Adulteração detectada:\n${e.message}';
      }
    });
  }

  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Validations BR — Exemplos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Validações de CPF ───────────────────────────────────────────
            _sectionTitle('AllValidations — CPF'),
            _resultRow(
                'isCpf("00000000000")', AllValidations.isCpf('00000000000')),
            _resultRow('isCpf("728.551.470-50")',
                AllValidations.isCpf('728.551.470-50')),
            _resultRow(
                'isCpf("72855147050")', AllValidations.isCpf('72855147050')),

            const Divider(height: 32),

            // ── HelperUtil — utilitários gerais ─────────────────────────────
            _sectionTitle('HelperUtil — utilitários gerais'),
            _labelValue(
              'countWords("Flutter é incrível")',
              '${HelperUtil.countWords("Flutter é incrível")}',
            ),
            _labelValue(
              'removeHtmlTags("<p>Olá <b>Mundo</b></p>")',
              HelperUtil.removeHtmlTags('<p>Olá <b>Mundo</b></p>'),
            ),
            _labelValue(
              'capitalizeWords("flutter é incrível")',
              HelperUtil.capitalizeWords('flutter é incrível'),
            ),
            _labelValue(
              'formatCurrency(1234.56)',
              BrFormatter.formatCurrency(1234.56),
            ),
            _labelValue(
              'daysBetween(01/01/2024, 31/12/2024)',
              '${HelperUtil.daysBetween(DateTime(2024, 1, 1), DateTime(2024, 12, 31))} dias',
            ),
            _labelValue(
              'generateUUIDv4()',
              HelperUtil.generateUUIDv4(),
            ),
            _labelValue(
              'validatePixKey("+5511912345678")',
              HelperUtil.validatePixKey('+5511912345678') ?? 'inválida',
            ),
            _labelValue(
              'maskPixKey("99286479174")',
              HelperUtil.maskPixKey('99286479174'),
            ),

            const Divider(height: 32),

            // ── Máscaras de Campo ───────────────────────────────────────────
            _sectionTitle('Máscaras de Campo — BrInputMask'),
            const Text(
              'Digite para ver a máscara aplicada em tempo real:',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            _maskField('CPF', [const CpfMask()],
                keyboardType: TextInputType.number),
            _maskField('CNPJ', [const CnpjMask()],
                keyboardType: TextInputType.number),
            _maskField('CNPJ Alfanumérico (2026)', [const CnpjAlfaMask()],
                keyboardType: TextInputType.text),
            _maskField('Telefone', [const PhoneMask()],
                keyboardType: TextInputType.phone),
            _maskField('CEP', [const CepMask()],
                keyboardType: TextInputType.number),
            _maskField('Data (DD/MM/AAAA)', [const DateMask()],
                keyboardType: TextInputType.number),
            _maskField('Hora (HH:MM)', [const TimeMask()],
                keyboardType: TextInputType.number),
            _maskField('Valor em R\$', [const CurrencyMask()],
                keyboardType: TextInputType.number),
            _maskField('Número do Cartão', [const CardMask()],
                keyboardType: TextInputType.number),
            _maskField('Validade do Cartão (MM/AA)', [const CardExpiryMask()],
                keyboardType: TextInputType.number),
            _maskField('CPF ou CNPJ (dinâmico)', [const CpfOuCnpjMask()],
                keyboardType: TextInputType.number),
            _maskField('Placa de Veículo', [const PlacaMask()],
                keyboardType: TextInputType.text),
            _maskField('Quilometragem', [const KmMask()],
                keyboardType: TextInputType.number),
            _maskField('Centavos (sem R\$)', [const CentavosMask()],
                keyboardType: TextInputType.number),
            _maskField('NCM', [const NcmMask()],
                keyboardType: TextInputType.number),
            _maskField('CNS (Cartão Nacional de Saúde)', [const CnsMask()],
                keyboardType: TextInputType.number),
            _maskField('Altura (m)', [const AlturaMask()],
                keyboardType: TextInputType.number),
            _maskField('Peso (kg)', [const PesoMask()],
                keyboardType: TextInputType.number),
            _maskField('Temperatura (°C)', [const TemperaturaMask()],
                keyboardType: TextInputType.number),

            const Divider(height: 32),

            // ── CryptUtil — ChaCha20-Poly1305 ───────────────────────────────
            _sectionTitle('CryptUtil — ChaCha20-Poly1305'),
            Text(
              'Chave (${_cryptKey.length} bytes): ${base64.encode(_cryptKey).substring(0, 16)}…',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _runCryptDemo,
                  child: const Text('Encriptar / Decriptar'),
                ),
                ElevatedButton(
                  onPressed: _runTamperingDemo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Simular adulteração'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_encryptedBase64.isNotEmpty) ...[
              _label('Ciphertext (base64):'),
              _mono(_encryptedBase64),
              const SizedBox(height: 8),
              _label('Decriptado:'),
              _mono(_decryptedText),
            ],
            if (_cryptError.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _cryptError,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],

            const Divider(height: 32),

            // ── CryptUtil — resultados estáticos ────────────────────────────
            _sectionTitle('CryptUtil — exemplos estáticos'),
            Builder(builder: (_) {
              final key = CryptUtil.generateKey();
              final payload = CryptUtil.encryptText('Olá, Brasil!', key: key);
              final decrypted = CryptUtil.decryptText(payload);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _labelValue('Texto original', 'Olá, Brasil!'),
                  _labelValue(
                      'Tag (hex)',
                      payload.tag
                          .map((b) => b.toRadixString(16).padLeft(2, '0'))
                          .join()),
                  _labelValue('Decriptado', decrypted),
                  _labelValue(
                    'Round-trip correto?',
                    decrypted == 'Olá, Brasil!' ? '✅ sim' : '❌ não',
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Widgets auxiliares ────────────────────────────────────────────────────

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );

  Widget _resultRow(String label, bool value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontFamily: 'monospace', fontSize: 12))),
            Text(
              value ? '✅ true' : '❌ false',
              style: TextStyle(
                  color: value ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );

  Widget _labelValue(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black, fontSize: 13),
            children: [
              TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.black54)),
              TextSpan(
                  text: value,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.black54),
      );

  Widget _mono(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
        ),
      );

  Widget _maskField(
    String label,
    List<TextInputFormatter> formatters, {
    TextInputType keyboardType = TextInputType.text,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: TextField(
          keyboardType: keyboardType,
          inputFormatters: formatters,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
        ),
      );
}
