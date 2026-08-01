/// Valida o subconjunto de endereços de e-mail suportado pelo pacote.
///
/// A regra é intencionalmente menor que a RFC 5322 e compartilhada pelas
/// APIs `AllValidations`, `Contract` e `BrZod`.
bool isAllowedEmail(String value) {
  final parts = value.split('@');
  if (parts.length != 2) return false;

  final local = parts[0];
  final domain = parts[1];
  final localPart = RegExp(
    r'^[A-Za-z0-9_+\-]+(?:\.[A-Za-z0-9_+\-]+)*$',
  );
  if (!localPart.hasMatch(local)) return false;

  final labels = domain.split('.');
  if (labels.length < 2) return false;
  if (!RegExp(r'^[A-Za-z]{2,}$').hasMatch(labels.last)) return false;

  final domainLabel = RegExp(
    r'^[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?$',
  );
  return labels.every(
    (label) => label.length <= 63 && domainLabel.hasMatch(label),
  );
}
