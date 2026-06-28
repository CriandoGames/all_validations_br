/// Funções puras de validação de documentos brasileiros usadas pelo [BrZod].
///
/// Separadas da classe principal para facilitar testes unitários
/// e eventual extração do módulo como pacote standalone.
///
/// Todos os métodos aceitam strings com ou sem máscara.
library;

// ── CPF ─────────────────────────────────────────────────────

/// Valida CPF (com ou sem máscara). Verifica dígitos verificadores via módulo 11.
bool isCpf(dynamic value) {
  final numbers = value?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '';
  if (numbers.length != 11) return false;
  if (RegExp(r'^(\d)\1{10}$').hasMatch(numbers)) return false;

  final digits = numbers.split('').map(int.parse).toList();

  var sum1 = 0;
  for (var i = 0; i < 9; i++) {
    sum1 += digits[i] * (10 - i);
  }
  final dv1 = (sum1 % 11) < 2 ? 0 : 11 - (sum1 % 11);
  if (digits[9] != dv1) return false;

  var sum2 = 0;
  for (var i = 0; i < 10; i++) {
    sum2 += digits[i] * (11 - i);
  }
  final dv2 = (sum2 % 11) < 2 ? 0 : 11 - (sum2 % 11);
  return digits[10] == dv2;
}

// ── CNPJ ────────────────────────────────────────────────────

/// Valida CNPJ numérico (com ou sem máscara). Dígitos verificadores via módulo 11.
bool isCnpj(dynamic value) {
  final numbers = value?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '';
  if (numbers.length != 14) return false;
  if (RegExp(r'^(\d)\1{13}$').hasMatch(numbers)) return false;

  final digits = numbers.split('').map(int.parse).toList();

  var sum1 = 0;
  var j = 0;
  for (var i in Iterable<int>.generate(12, (i) => i < 4 ? 5 - i : 13 - i)) {
    sum1 += digits[j++] * i;
  }
  final dv1 = (sum1 % 11) < 2 ? 0 : 11 - (sum1 % 11);
  if (digits[12] != dv1) return false;

  var sum2 = 0;
  j = 0;
  for (var i in Iterable<int>.generate(13, (i) => i < 5 ? 6 - i : 14 - i)) {
    sum2 += digits[j++] * i;
  }
  final dv2 = (sum2 % 11) < 2 ? 0 : 11 - (sum2 % 11);
  return digits[13] == dv2;
}

/// Valida CNPJ alfanumérico — IN RFB 2229/2024 (vigente a partir de julho/2026).
///
/// Aceita letras A–Z nos primeiros 12 caracteres. Os dígitos verificadores
/// continuam sendo numéricos. Aceita com ou sem máscara.
bool isCnpjAlfa(dynamic value) {
  if (value == null) return false;
  final s = value.toString().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  if (s.length != 14) return false;
  if (RegExp(r'^(.)\1{13}$').hasMatch(s)) return false;

  // Os dois últimos caracteres devem ser dígitos (DV sempre numérico)
  if (!RegExp(r'^\d{2}$').hasMatch(s.substring(12))) return false;

  int val(int cu) => (cu >= 48 && cu <= 57) ? cu - 48 : cu - 55;

  int calc(String body) {
    int weight = 2, sum = 0;
    for (int i = body.length - 1; i >= 0; i--) {
      sum += val(body.codeUnitAt(i)) * weight;
      weight = weight == 9 ? 2 : weight + 1;
    }
    final mod = sum % 11;
    return mod < 2 ? 0 : 11 - mod;
  }

  final dv1 = calc(s.substring(0, 12));
  if (dv1 != int.parse(s[12])) return false;

  final dv2 = calc(s.substring(0, 13));
  return dv2 == int.parse(s[13]);
}

/// Valida CPF **ou** CNPJ (numérico).
bool isCpfOuCnpj(dynamic value) => isCpf(value) || isCnpj(value);

// ── CEP ─────────────────────────────────────────────────────

/// Valida CEP brasileiro no formato `00000-000` ou `00000000`.
bool isCep(dynamic value) {
  final s = value?.toString() ?? '';
  final digits = s.replaceAll(RegExp(r'\D'), '');
  return digits.length == 8 && RegExp(r'^\d{8}$').hasMatch(digits);
}

// ── RG ──────────────────────────────────────────────────────

/// Valida RG no padrão mais comum: 1–2 dígitos, 3, 3 e 1 dígito (ou X).
///
/// Aceita com ou sem pontuação. Não valida dígito verificador
/// (cada estado tem regras distintas).
bool isRg(dynamic value) {
  final s = value?.toString() ?? '';
  return RegExp(
    r'(^\d{1,2}).?(\d{3}).?(\d{3})-?(\d{1}|X|x$)',
    caseSensitive: false,
  ).hasMatch(s);
}

// ── Placa veicular ───────────────────────────────────────────

/// Valida placa veicular brasileira — formato antigo (`ABC-1234`)
/// e Mercosul (`ABC1D23`), com ou sem hífen.
bool isPlaca(dynamic value) {
  final s = value?.toString().toUpperCase().trim() ?? '';
  final old = RegExp(r'^[A-Z]{3}-?\d{4}$');
  final mercosul = RegExp(r'^[A-Z]{3}\d[A-Z]\d{2}$');
  return old.hasMatch(s) || mercosul.hasMatch(s);
}

// ── CNH ─────────────────────────────────────────────────────

/// Valida CNH (Carteira Nacional de Habilitação) — 11 dígitos,
/// dois dígitos verificadores via módulo 11.
bool isCnh(dynamic value) {
  final numbers = value?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '';
  if (numbers.length != 11) return false;
  if (RegExp(r'^(\d)\1{10}$').hasMatch(numbers)) return false;

  final digits = numbers.split('').map(int.parse).toList();

  // Primeiro DV
  int sum1 = 0;
  int secondFlag = 0;
  for (int i = 0; i < 9; i++) {
    sum1 += digits[i] * (9 - i);
  }
  int dv1 = sum1 % 11;
  if (dv1 >= 10) {
    dv1 = 0;
    secondFlag = 2;
  }
  if (digits[9] != dv1) return false;

  // Segundo DV
  int sum2 = 0;
  for (int i = 0; i < 9; i++) {
    sum2 += digits[i] * (1 + i);
  }
  int dv2;
  if (secondFlag == 2) {
    dv2 = (sum2 % 11 == 0) ? 0 : 11 - (sum2 % 11);
  } else {
    dv2 = sum2 % 11 >= 10 ? 0 : sum2 % 11;
  }
  return digits[10] == dv2;
}

// ── RENAVAM ──────────────────────────────────────────────────

/// Valida RENAVAM (9 ou 11 dígitos) via módulo 11.
bool isRenavam(dynamic value) {
  final numbers = value?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '';
  if (numbers.length < 9 || numbers.length > 11) return false;

  final padded = numbers.padLeft(11, '0');
  if (RegExp(r'^(\d)\1{10}$').hasMatch(padded)) return false;

  final digits = padded.split('').map(int.parse).toList();
  const weights = [3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

  int sum = 0;
  for (int i = 0; i < 10; i++) {
    sum += digits[i] * weights[i];
  }
  final dv = (sum % 11) < 2 ? 0 : 11 - (sum % 11);
  return digits[10] == dv;
}

// ── PIS / PASEP ──────────────────────────────────────────────

/// Valida PIS/PASEP — 11 dígitos, módulo 11 com pesos 3,2,9,8,7,6,5,4,3,2.
bool isPisPasep(dynamic value) {
  final numbers = value?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '';
  if (numbers.length != 11) return false;
  if (RegExp(r'^(\d)\1{10}$').hasMatch(numbers)) return false;

  const weights = [3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
  final digits = numbers.split('').map(int.parse).toList();

  int sum = 0;
  for (int i = 0; i < 10; i++) {
    sum += digits[i] * weights[i];
  }
  final dv = (sum % 11) < 2 ? 0 : 11 - (sum % 11);
  return digits[10] == dv;
}

// ── Título de Eleitor ────────────────────────────────────────

/// Valida Título de Eleitor brasileiro — 12 dígitos, dois DVs via módulo 11.
bool isTituloEleitor(dynamic value) {
  final numbers = value?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '';
  if (numbers.length != 12) return false;
  if (RegExp(r'^(\d)\1{11}$').hasMatch(numbers)) return false;

  final digits = numbers.split('').map(int.parse).toList();

  final estado = int.parse(numbers.substring(8, 10));
  if (estado < 1 || estado > 28) return false;

  // Primeiro DV (posições 0–7)
  const w1 = [2, 3, 4, 5, 6, 7, 8, 9];
  int sum1 = 0;
  for (int i = 0; i < 8; i++) {
    sum1 += digits[i] * w1[i];
  }
  int dv1 = sum1 % 11;
  if (estado == 1 || estado == 2) {
    if (dv1 == 0) dv1 = 1;
  } else {
    if (dv1 >= 10) dv1 = 0;
  }
  if (digits[10] != dv1) return false;

  // Segundo DV (posições 8–10)
  const w2 = [7, 8, 9];
  int sum2 = 0;
  for (int i = 0; i < 3; i++) {
    sum2 += digits[8 + i] * w2[i];
  }
  int dv2 = sum2 % 11;
  if (estado == 1 || estado == 2) {
    if (dv2 == 0) dv2 = 1;
  } else {
    if (dv2 >= 10) dv2 = 0;
  }
  return digits[11] == dv2;
}

// ── CNS ─────────────────────────────────────────────────────

/// Valida Cartão Nacional de Saúde (CNS) — 15 dígitos.
///
/// Algoritmo DATASUS:
/// - Começa com 7, 8 ou 9 (definitivo): soma ponderada % 11 == 0
/// - Começa com 1 ou 2 (provisório): idem (gerado de modo que satisfaz a mesma condição)
bool isCns(dynamic value) {
  final numbers = value?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '';
  if (numbers.length != 15) return false;

  final first = int.parse(numbers[0]);
  if (![1, 2, 7, 8, 9].contains(first)) return false;

  // Soma ponderada: digit[i] * (15 - i), i = 0..14
  int sum = 0;
  for (int i = 0; i < 15; i++) {
    sum += int.parse(numbers[i]) * (15 - i);
  }
  return sum % 11 == 0;
}
