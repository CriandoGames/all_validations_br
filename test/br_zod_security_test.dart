import 'package:all_validations_br/src/br_zod/validations/security.dart' as sec;
import 'package:all_validations_br/src/br_zod/br_zod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── isPassword ───────────────────────────────────────────────
  group('isPassword — forte (padrão)', () {
    test('válida forte', () => expect(sec.isPassword('Abc@1234'), isTrue));
    test('sem maiúscula', () => expect(sec.isPassword('abc@1234'), isFalse));
    test('sem minúscula', () => expect(sec.isPassword('ABC@1234'), isFalse));
    test('sem número', () => expect(sec.isPassword('Abcdefg@'), isFalse));
    test('sem símbolo', () => expect(sec.isPassword('Abcdefg1'), isFalse));
    test('menos de 8', () => expect(sec.isPassword('Abc@12'), isFalse));
    test('null', () => expect(sec.isPassword(null), isFalse));
  });

  group('isPassword — média', () {
    test('maiúsc + minúsc + número, 6+', () {
      expect(sec.isPassword('Abc123', policy: PasswordPolicy.medium), isTrue);
    });
    test('sem número', () {
      expect(sec.isPassword('Abcdef', policy: PasswordPolicy.medium), isFalse);
    });
    test('menos de 6', () {
      expect(sec.isPassword('Ab1', policy: PasswordPolicy.medium), isFalse);
    });
  });

  group('isPassword — fraca', () {
    test('só letras, 6+', () {
      expect(sec.isPassword('abcdef', policy: PasswordPolicy.weak), isTrue);
    });
    test('menos de 6', () {
      expect(sec.isPassword('abc', policy: PasswordPolicy.weak), isFalse);
    });
  });

  group('isPassword — customizada', () {
    const policy = PasswordPolicy(minLength: 12, requireSpecial: false);
    test('12 chars sem símbolo — ok', () {
      expect(sec.isPassword('Abcdefghij12', policy: policy), isTrue);
    });
    test('11 chars — curto', () {
      expect(sec.isPassword('Abcdefghij1', policy: policy), isFalse);
    });
  });

  // ── isUuid ───────────────────────────────────────────────────
  group('isUuid', () {
    const v4 = '550e8400-e29b-41d4-a716-446655440000';
    const v3 = '6ba7b810-9dad-31d1-80b4-00c04fd430c8';
    test('v4 válido (all)', () => expect(sec.isUuid(v4), isTrue));
    test('v4 válido (version 4)',
        () => expect(sec.isUuid(v4, version: '4'), isTrue));
    test('v4 rejeitado como v3',
        () => expect(sec.isUuid(v4, version: '3'), isFalse));
    test('v3 válido (all)', () => expect(sec.isUuid(v3), isTrue));
    test('minúsculas aceitas',
        () => expect(sec.isUuid(v4.toLowerCase()), isTrue));
    test('sem hífens',
        () => expect(sec.isUuid('550e8400e29b41d4a716446655440000'), isFalse));
    test('null', () => expect(sec.isUuid(null), isFalse));
  });

  // ── isUrl ────────────────────────────────────────────────────
  group('isUrl', () {
    test('https', () => expect(sec.isUrl('https://example.com'), isTrue));
    test('http com path',
        () => expect(sec.isUrl('http://example.com/path?q=1'), isTrue));
    test('ftp', () => expect(sec.isUrl('ftp://files.example.com'), isTrue));
    test('localhost', () => expect(sec.isUrl('http://localhost:8080'), isTrue));
    test('IP', () => expect(sec.isUrl('http://192.168.1.1'), isTrue));
    test('sem esquema', () => expect(sec.isUrl('example.com'), isFalse));
    test('esquema inválido',
        () => expect(sec.isUrl('ws://example.com'), isFalse));
    test('null', () => expect(sec.isUrl(null), isFalse));
  });

  // ── isIpv4 ───────────────────────────────────────────────────
  group('isIpv4', () {
    test('válido', () => expect(sec.isIpv4('192.168.0.1'), isTrue));
    test('zeros', () => expect(sec.isIpv4('0.0.0.0'), isTrue));
    test('máximo', () => expect(sec.isIpv4('255.255.255.255'), isTrue));
    test('255+ inválido', () => expect(sec.isIpv4('256.0.0.1'), isFalse));
    test('3 octetos', () => expect(sec.isIpv4('192.168.1'), isFalse));
    test('com letras', () => expect(sec.isIpv4('192.168.a.1'), isFalse));
    test('zero à esquerda', () => expect(sec.isIpv4('01.02.03.04'), isFalse));
    test('null', () => expect(sec.isIpv4(null), isFalse));
  });

  // ── isIpv6 ───────────────────────────────────────────────────
  group('isIpv6', () {
    test('completo', () {
      expect(sec.isIpv6('2001:0db8:85a3:0000:0000:8a2e:0370:7334'), isTrue);
    });
    test('comprimido ::', () {
      expect(sec.isIpv6('::1'), isTrue);
    });
    test('loopback', () => expect(sec.isIpv6('::1'), isTrue));
    test('misto comprimido', () {
      expect(sec.isIpv6('2001:db8::1'), isTrue);
    });
    test('com zona %eth0', () {
      expect(sec.isIpv6('fe80::1%eth0'), isTrue);
    });
    test('IPv4 inválido como IPv6', () {
      expect(sec.isIpv6('192.168.0.1'), isFalse);
    });
    test('null', () => expect(sec.isIpv6(null), isFalse));
  });

  // ── matchesRegex ─────────────────────────────────────────────
  group('matchesRegex', () {
    test('4 dígitos — válido', () {
      expect(sec.matchesRegex('1234', r'^\d{4}$'), isTrue);
    });
    test('4 dígitos — inválido', () {
      expect(sec.matchesRegex('12345', r'^\d{4}$'), isFalse);
    });
    test('hex color', () {
      expect(sec.matchesRegex('#FF5733', r'^#[0-9A-Fa-f]{6}$'), isTrue);
    });
    test('null retorna false', () {
      expect(sec.matchesRegex(null, r'^\d+$'), isFalse);
    });
  });

  // ── BrZod fluente — segurança ─────────────────────────────────
  group('BrZod encadeado — segurança', () {
    test('password forte — válida', () {
      expect(BrZod().required().password().build('Abc@1234'), isNull);
    });
    test('password forte — inválida', () {
      expect(BrZod().required().password().build('senha123'), isNotNull);
    });
    test('password média', () {
      expect(
        BrZod()
            .required()
            .password(policy: PasswordPolicy.medium)
            .build('Abc123'),
        isNull,
      );
    });
    test('uuid — válido', () {
      expect(
        BrZod().required().uuid().build('550e8400-e29b-41d4-a716-446655440000'),
        isNull,
      );
    });
    test('uuid v4 — inválido como v3', () {
      expect(
        BrZod()
            .required()
            .uuid(version: '3')
            .build('550e8400-e29b-41d4-a716-446655440000'),
        isNotNull,
      );
    });
    test('url — válida', () {
      expect(BrZod().required().url().build('https://example.com'), isNull);
    });
    test('url — inválida', () {
      expect(BrZod().required().url().build('not-a-url'), isNotNull);
    });
    test('ipv4 — válido', () {
      expect(BrZod().required().ipv4().build('192.168.0.1'), isNull);
    });
    test('ipv4 — inválido', () {
      expect(BrZod().required().ipv4().build('999.0.0.1'), isNotNull);
    });
    test('ipv6 — válido', () {
      expect(BrZod().required().ipv6().build('::1'), isNull);
    });
    test('regex — match', () {
      expect(BrZod().required().regex(r'^\d{4}$').build('1234'), isNull);
    });
    test('regex — no match', () {
      expect(BrZod().required().regex(r'^\d{4}$').build('abcd'), isNotNull);
    });
    test('regex — mensagem customizada', () {
      expect(
        BrZod()
            .required()
            .regex(r'^\d{4}$', message: 'Só 4 dígitos')
            .build('abcd'),
        equals('Só 4 dígitos'),
      );
    });
    test('optional + password — vazio ok', () {
      expect(BrZod().optional().password().build(''), isNull);
    });
    test('encadeamento completo: required + min + password', () {
      final v = BrZod().required().min(8).password().build;
      expect(v('Abc@12'), isNotNull); // curto
      expect(v('Abc@1234'), isNull); // ok
    });
  });
}
