/// Biblioteca principal do pacote — exporta todos os módulos em uma única importação.
///
/// Inclui validações brasileiras, máscaras de campo, formatadores, utilitários,
/// `Contract`/`Result` para validação de domínio e criptografia autenticada.
///
/// ## Importação
///
/// ```dart
/// import 'package:all_validations_br/all_validations_br.dart';
/// ```
///
/// ## O que está incluído
///
/// | Módulo | Classes principais |
/// |--------|--------------------|
/// | Validações | `AllValidations` — CPF, CNPJ, CNH, RENAVAM, PIS, Título, CEP, Placa, PIX, EAN-13 |
/// | Formatadores | `BrFormatter`, `BrData` — CPF, CNPJ, moeda, datas (sem `intl`) |
/// | Máscaras | `BrInputMask` + 24 máscaras especializadas para `TextField` |
/// | CNPJ 2026 | `CnpjAlfanumerico` — IN RFB 2229/2024: validação, formatação, geração |
/// | Contrato | `Contract`, `ValidationNotifiable` — validação acumulativa de entidades |
/// | Result | `Result<F,S>`, `ContractValidations` — programação orientada a trilhos |
/// | Utilitários | `HelperUtil` — UUID, JWT, PIX, datas, strings, maioridade |
/// | Criptografia | `AllCrypto`/`CryptEnvelope` — chave externa e payload v2; `CryptUtil` legado |
/// | Modelos | `AllValidationsGetMonth`, `AllValidationsGetStates`, `AllValidationsGetRegions` |
///
/// ## Barrels históricos
///
/// Estes imports continuam disponíveis, embora o barrel principal também
/// exponha os símbolos dos cinco pacotes especializados:
///
/// ```dart
/// import 'package:all_validations_br/br_zod.dart';  // validador fluente
/// import 'package:all_validations_br/br_logger.dart'; // logging puro
/// import 'package:all_validations_br/crypt.dart';   // apenas criptografia
/// ```
///
/// ## Exemplos rápidos
///
/// ```dart
/// // Validação direta
/// AllValidations.isCpf('529.982.247-25'); // true
///
/// // Máscara em TextField
/// TextField(inputFormatters: [CpfMask()])
///
/// // Contract em entidade
/// Contract().isEmail(email, 'email', 'E-mail inválido').hasMinLen(nome, 2, 'nome', 'Mínimo 2')
///
/// // Result assíncrono
/// final r = await Result.tryAsync(() => dio.get('/api'), onError: (e, _) => '$e');
///
/// // Criptografia — ChaCha20-Poly1305 e envelope v2 (padrão)
/// final key = AllCrypto.generateKey(); // mantenha em um cofre externo
/// final envelope = AllCrypto.encryptText('segredo', key: key);
/// final encoded = envelope.toBase64(); // nunca inclui a chave
/// final decoded = CryptEnvelope.fromBase64(encoded);
/// final plain = AllCrypto.decryptText(decoded, key: key);
/// ```
library all_validations_br;

export 'package:all_br_validations/all_br_validations.dart';
export 'package:all_br_forms/all_br_forms.dart';
export 'package:all_crypto/all_crypto.dart';
export 'package:all_logger/all_logger.dart';
export './src/helper_utils/helper_util.dart';
export 'package:all_result/all_result.dart';
