import 'package:all_observer/all_observer.dart';
import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

/// Estado reativo confinado ao aplicativo de exemplo.
///
/// `all_observer` demonstra apenas a reação da interface às operações do
/// ecossistema; não é dependência de runtime de nenhum pacote publicável.
class ExamplesController {
  final cryptKey = AllCrypto.generateKey();
  final logOutput = BrMemoryOutput(maxRecords: 10);
  final encryptedBase64 = Observable<String>('');
  final decryptedText = Observable<String>('');
  final cryptError = Observable<String>('');
  final lastLog = Observable<String>('');

  late final logger = BrLogger(
    tag: 'ToolkitExample',
    filter: const BrAllFilter(),
    printer: const BrSimplePrinter(showTime: false),
    output: logOutput,
  );

  late final Computed<bool> hasEncrypted =
      Computed(() => encryptedBase64.value.isNotEmpty);
  late final Computed<bool> hasError =
      Computed(() => cryptError.value.isNotEmpty);

  late final staticPayload = AllCrypto.encryptText(
    'Olá, Brasil!',
    key: cryptKey,
  );
  late final staticDecrypted = AllCrypto.decryptText(
    staticPayload,
    key: cryptKey,
  );

  void runCryptDemo() {
    try {
      const plaintext = 'Dados sensíveis do usuário 🔒';
      final envelope = AllCrypto.encryptText(plaintext, key: cryptKey);
      final encrypted = envelope.toBase64();
      final restored = CryptEnvelope.fromBase64(encrypted);
      final decrypted = AllCrypto.decryptText(restored, key: cryptKey);

      Observable.batch(() {
        cryptError.value = '';
        encryptedBase64.value = encrypted;
        decryptedText.value = decrypted;
      });
    } on CryptException catch (error) {
      Observable.batch(() {
        encryptedBase64.value = '';
        decryptedText.value = '';
        cryptError.value = error.toString();
      });
    }
  }

  void runTamperingDemo() {
    try {
      final payload = AllCrypto.encryptText('segredo', key: cryptKey);
      final tampered = CryptEnvelope(
        ciphertext: Uint8List.fromList(
          List<int>.from(payload.ciphertext)..[0] ^= 0xFF,
        ),
        algorithm: payload.algorithm,
        tag: payload.tag,
        nonce: payload.nonce,
        aad: payload.aad,
      );

      AllCrypto.decryptText(tampered, key: cryptKey);
    } on CryptException catch (error) {
      Observable.batch(() {
        encryptedBase64.value = '';
        decryptedText.value = '';
        cryptError.value = '✅ Adulteração detectada:\n${error.message}';
      });
    }
  }

  String validateCpfWithResult(String cpf) {
    final error = BrZod().required().cpf().build(cpf);
    final result = error == null
        ? Result.success<String, String>(cpf)
        : Result.failure<String, String>(error);

    return result.fold(
      (failure) => 'Falha: $failure',
      (value) => 'Sucesso: CPF ${BrFormatter.formatCpf(value)}',
    );
  }

  void runLoggerDemo() {
    logger.info('fluxo integrado concluído');
    final record = logOutput.records.last;
    lastLog.value = '${record.level.name.toUpperCase()} '
        '[${record.tag}] ${record.message}';
  }

  void dispose() {
    logger.dispose();
    hasEncrypted.close();
    hasError.close();
    encryptedBase64.close();
    decryptedText.close();
    cryptError.close();
    lastLog.close();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.controller});

  final ExamplesController? controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'All Validations BR — Exemplos',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ExamplesPage(controller: controller),
    );
  }
}

class ExamplesPage extends StatefulWidget {
  const ExamplesPage({super.key, this.controller});

  final ExamplesController? controller;

  @override
  State<ExamplesPage> createState() => _ExamplesPageState();
}

class _ExamplesPageState extends State<ExamplesPage> {
  late final ExamplesController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? ExamplesController();
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

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
            _labelValue(
              'BrZod + Result',
              _controller.validateCpfWithResult('52998224725'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              inputFormatters: const [PhoneMask()],
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: BrZod().required().phone().build,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefone — máscara + validação',
                hintText: '(11) 91234-5678',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),

            const Divider(height: 32),

            _sectionTitle('AllLogger — pipeline testável'),
            const Text(
              'O exemplo usa BrMemoryOutput: nenhum dado é enviado para rede.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _controller.runLoggerDemo,
              child: const Text('Registrar evento seguro'),
            ),
            Observer(() {
              if (_controller.lastLog.value.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _mono(_controller.lastLog.value),
              );
            }),

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
              AllValidations.validatePixKey('+5511912345678').successValue.name,
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
            _maskField('CEST', [const CestMask()],
                keyboardType: TextInputType.number),
            _maskField('IOF (alíquota)', [const IofMask()],
                keyboardType: TextInputType.number),
            _maskField('NUP (protocolo federal)', [const NupMask()],
                keyboardType: TextInputType.number),
            _maskField('Certidão de Nascimento', [const CertNascimentoMask()],
                keyboardType: TextInputType.number),

            const Divider(height: 32),

            // ── AllCrypto — envelope seguro v2 ─────────────────────────────
            _sectionTitle('AllCrypto — envelope seguro v2'),
            const Text(
              'Chave sintética gerada em memória; não serializada nem exibida.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _controller.runCryptDemo,
                  child: const Text('Encriptar / Decriptar'),
                ),
                ElevatedButton(
                  onPressed: _controller.runTamperingDemo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Simular adulteração'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Observer(() {
              if (!_controller.hasEncrypted.value) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Ciphertext (base64):'),
                  _mono(_controller.encryptedBase64.value),
                  const SizedBox(height: 8),
                  _label('Decriptado:'),
                  _mono(_controller.decryptedText.value),
                ],
              );
            }),
            Observer(() {
              if (!_controller.hasError.value) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  key: const ValueKey('crypt-error'),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _controller.cryptError.value,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              );
            }),

            const Divider(height: 32),

            // ── AllCrypto — resultados estáticos ────────────────────────────
            _sectionTitle('AllCrypto — exemplos estáticos'),
            _labelValue('Texto original', 'Olá, Brasil!'),
            _labelValue(
              'Tag (hex)',
              _controller.staticPayload.tag
                  .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
                  .join(),
            ),
            _labelValue('Decriptado', _controller.staticDecrypted),
            _labelValue(
              'Round-trip correto?',
              _controller.staticDecrypted == 'Olá, Brasil!' ? '✅ sim' : '❌ não',
            ),
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
