import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── Result.tryAsync ───────────────────────────────────────────────────────

  group('Result.tryAsync', () {
    test('retorna Success quando Future completa', () async {
      final r = await Result.tryAsync<String, int>(
        () async => 42,
        onError: (e, _) => 'erro',
      );
      expect(r.successValue, 42);
    });

    test('retorna Failure quando Future lança', () async {
      final r = await Result.tryAsync<String, int>(
        () async => throw Exception('boom'),
        onError: (e, _) => 'capturado',
      );
      expect(r.failureValue, 'capturado');
    });

    test('passa o erro e stack para onError', () async {
      Object? capturado;
      await Result.tryAsync<Object, int>(
        () async => throw ArgumentError('x'),
        onError: (e, st) {
          capturado = e;
          return e;
        },
      );
      expect(capturado, isA<ArgumentError>());
    });
  });

  group('Result.tryAsyncTyped', () {
    test('captura apenas o tipo especificado', () async {
      final r = await Result.tryAsyncTyped<FormatException, String, int>(
        () async => int.parse('abc'),
        onError: (e, _) => 'formato inválido',
      );
      expect(r.failureValue, 'formato inválido');
    });

    test('deixa passar exceções de outro tipo', () async {
      expect(
        () => Result.tryAsyncTyped<ArgumentError, String, int>(
          () async => throw StateError('outro'),
          onError: (e, _) => 'não chega aqui',
        ),
        throwsStateError,
      );
    });
  });

  // ── FutureResult extension ────────────────────────────────────────────────

  group('FutureResult.mapAsync', () {
    test('transforma Success de forma async', () async {
      final r = await Result.tryAsync<String, int>(
        () async => 3,
        onError: (e, _) => 'err',
      ).mapAsync((n) async => n * 2);
      expect(r.successValue, 6);
    });

    test('não aplica em Failure', () async {
      final r = await Result.tryAsync<String, int>(
        () async => throw Exception(),
        onError: (e, _) => 'err',
      ).mapAsync((n) async => n * 2);
      expect(r.failureValue, 'err');
    });
  });

  group('FutureResult.thenAsync', () {
    test('encadeia Future<Result> → Success', () async {
      final r = await Result.tryAsync<String, int>(
        () async => 5,
        onError: (e, _) => 'err',
      ).thenAsync((n) async => Result.success<String, int>(n + 1));
      expect(r.successValue, 6);
    });

    test('encadeia Future<Result> → Failure', () async {
      final r = await Result.tryAsync<String, int>(
        () async => 5,
        onError: (e, _) => 'err',
      ).thenAsync((_) async => Result.failure<String, int>('parou'));
      expect(r.failureValue, 'parou');
    });

    test('Failure ignora thenAsync', () async {
      int calls = 0;
      final r = await Result.tryAsync<String, int>(
        () async => throw Exception(),
        onError: (e, _) => 'err',
      ).thenAsync((n) async {
        calls++;
        return Result.success<String, int>(n);
      });
      expect(r.failureValue, 'err');
      expect(calls, 0);
    });
  });

  group('FutureResult.foldAsync', () {
    test('chama onSuccess em Success', () async {
      final out = await Result.tryAsync<String, int>(
        () async => 10,
        onError: (e, _) => 'err',
      ).foldAsync((f) async => 'F', (s) async => 'S:$s');
      expect(out, 'S:10');
    });

    test('chama onFailure em Failure', () async {
      final out = await Result.tryAsync<String, int>(
        () async => throw Exception(),
        onError: (e, _) => 'err',
      ).foldAsync((f) async => 'F:$f', (s) async => 'S');
      expect(out, 'F:err');
    });
  });

  group('FutureResult.recoverAsync', () {
    test('converte Failure em Success async', () async {
      final r = await Result.tryAsync<String, int>(
        () async => throw Exception(),
        onError: (e, _) => 'err',
      ).recoverAsync((_) async => -1);
      expect(r.successValue, -1);
    });

    test('Success passa intacto', () async {
      final r = await Result.tryAsync<String, int>(
        () async => 5,
        onError: (e, _) => 'err',
      ).recoverAsync((_) async => -1);
      expect(r.successValue, 5);
    });
  });

  group('FutureResult.tapAsync / tapFailureAsync', () {
    test('tapAsync executa em Success', () async {
      int seen = 0;
      await Result.tryAsync<String, int>(
        () async => 7,
        onError: (e, _) => 'err',
      ).tapAsync((v) async => seen = v);
      expect(seen, 7);
    });

    test('tapFailureAsync executa em Failure', () async {
      String seen = '';
      await Result.tryAsync<String, int>(
        () async => throw Exception(),
        onError: (e, _) => 'falhou',
      ).tapFailureAsync((f) async => seen = f);
      expect(seen, 'falhou');
    });
  });

  group('FutureResult.getOrElse / toNullable', () {
    test('getOrElse retorna valor em Success', () async {
      final v = await Result.tryAsync<String, int>(
        () async => 3,
        onError: (e, _) => 'err',
      ).getOrElse(0);
      expect(v, 3);
    });

    test('getOrElse retorna default em Failure', () async {
      final v = await Result.tryAsync<String, int>(
        () async => throw Exception(),
        onError: (e, _) => 'err',
      ).getOrElse(0);
      expect(v, 0);
    });

    test('toNullable retorna null em Failure', () async {
      final v = await Result.tryAsync<String, int>(
        () async => throw Exception(),
        onError: (e, _) => 'err',
      ).toNullable();
      expect(v, isNull);
    });
  });

  // ── Railway chain completo ────────────────────────────────────────────────

  group('railway chain completo (HTTP simulado)', () {
    Future<String> fetchRaw() async => '{"id": 1, "name": "Carlos"}';

    Result<String, Map<String, dynamic>> parseJson(String raw) {
      try {
        // simula parse simples
        if (raw.startsWith('{'))
          return Result.success({'id': 1, 'name': 'Carlos'});
        return Result.failure('JSON inválido');
      } catch (_) {
        return Result.failure('JSON inválido');
      }
    }

    Result<String, String> extractName(Map<String, dynamic> json) {
      final name = json['name'] as String?;
      if (name == null || name.isEmpty) return Result.failure('Nome ausente');
      return Result.success(name);
    }

    test('chain completo retorna Success', () async {
      final result = await Result.tryAsync<String, String>(
        () => fetchRaw(),
        onError: (e, _) => 'Falha na requisição',
      )
          .thenAsync((raw) async => parseJson(raw))
          .thenAsync((json) async => extractName(json));

      expect(result.successValue, 'Carlos');
    });

    test('chain interrompido na primeira falha propaga Failure', () async {
      final result = await Result.tryAsync<String, String>(
        () async => throw Exception('timeout'),
        onError: (e, _) => 'Falha na requisição',
      )
          .thenAsync((raw) async => parseJson(raw))
          .thenAsync((json) async => extractName(json));

      expect(result.failureValue, 'Falha na requisição');
    });
  });
}
