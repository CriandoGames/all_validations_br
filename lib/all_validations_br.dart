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
/// | Máscaras | `BrInputMask` + 23 máscaras especializadas para `TextField` |
/// | CNPJ 2026 | `CnpjAlfanumerico` — IN RFB 2229/2024: validação, formatação, geração |
/// | Contrato | `Contract`, `ValidationNotifiable` — validação acumulativa de entidades |
/// | Result | `Result<F,S>`, `ContractValidations` — programação orientada a trilhos |
/// | Utilitários | `HelperUtil` — UUID, JWT, PIX, datas, strings, maioridade |
/// | Criptografia | `CryptUtil` — ChaCha20-Poly1305 (RFC 8439), zero dependências externas |
/// | Modelos | `AllValidationsGetMonth`, `AllValidationsGetStates`, `AllValidationsGetRegions` |
///
/// ## Módulos com importação separada
///
/// Estes módulos têm barrel próprio e **não** estão incluídos aqui:
///
/// ```dart
/// import 'package:all_validations_br/br_zod.dart';     // validador fluente
/// import 'package:all_validations_br/br_logger.dart';  // logging puro
/// ```
///
/// ## Exemplos rápidos
///
/// ```dart
/// // Validação direta
/// AllValidations.isCpf('529.982.247-25'); // true
///
/// // Máscara em TextField
/// TextField(inputFormatters: [BrInputMask.cpf()])
///
/// // Contract em entidade
/// Contract().isEmail(email, 'email', 'E-mail inválido').hasMinLen(nome, 2, 'nome', 'Mínimo 2')
///
/// // Result assíncrono
/// final r = await Result.tryAsync(() => dio.get('/api'), onError: (e, _) => '$e');
///
/// // Criptografia
/// final enc = CryptUtil.encryptToBase64('segredo');
/// final dec = CryptUtil.decryptFromBase64(enc);
/// ```
library all_validations_br;

export 'src/cnpj/cnpj_alfanumerico.dart';
export 'src/br_formatter/br_formatter.dart';
export 'src/br_formatter/br_data.dart';
export 'src/masks/br_input_mask.dart';
export 'src/masks/cpf_mask.dart';
export 'src/masks/cnpj_mask.dart';
export 'src/masks/cnpj_alfa_mask.dart';
export 'src/masks/phone_mask.dart';
export 'src/masks/cep_mask.dart';
export 'src/masks/date_mask.dart';
export 'src/masks/time_mask.dart';
export 'src/masks/currency_mask.dart';
export 'src/masks/card_mask.dart';
export 'src/masks/card_expiry_mask.dart';
export 'src/masks/expiry_mask.dart';
export 'src/masks/cpf_ou_cnpj_mask.dart';
export 'src/masks/placa_mask.dart';
export 'src/masks/km_mask.dart';
export 'src/masks/centavos_mask.dart';
export 'src/masks/ncm_mask.dart';
export 'src/masks/cns_mask.dart';
export 'src/masks/altura_mask.dart';
export 'src/masks/peso_mask.dart';
export 'src/masks/temperatura_mask.dart';
export 'src/masks/cest_mask.dart';
export 'src/masks/iof_mask.dart';
export 'src/masks/nup_mask.dart';
export 'src/masks/cert_nascimento_mask.dart';
export 'src/validator/all_validations.dart';
export 'src/models/models.dart';
export './src/notifications/notifiable.dart';
export './src/validator/contract.dart';
export './src/validator/contract_validations.dart';
export './src/helper_utils/helper_util.dart';
export './src/crypt/crypt_util.dart';
export './src/result/result_exports.dart';
export 'src/extensions/extensions.dart';
