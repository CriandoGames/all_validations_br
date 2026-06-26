import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── Construtores ──────────────────────────────────────────────────────────

  group('Result.success / Result.failure', () {
    test('Result.success cria Success com o valor correto', () {
      final r = Result.success<String, int>(42);
      expect(r.isSuccess, isTrue);
      expect(r.isFailure, isFalse);
      expect(r.successValue, 42);
    });

    test('Result.failure cria Failure com o erro correto', () {
      final r = Result.failure<String, int>('erro');
      expect(r.isFailure, isTrue);
      expect(r.isSuccess, isFalse);
      expect(r.failureValue, 'erro');
    });

    test('successValue em Failure lança StateError', () {
      final r = Result.failure<String, int>('erro');
      expect(() => r.successValue, throwsStateError);
    });

    test('failureValue em Success lança StateError', () {
      final r = Result.success<String, int>(1);
      expect(() => r.failureValue, throwsStateError);
    });
  });

  // ── Construtores utilitários ──────────────────────────────────────────────

  group('Result.cond', () {
    test('retorna Success quando test é true', () {
      final r = Result.cond(true, 'ok', 'erro');
      expect(r.isSuccess, isTrue);
      expect(r.successValue, 'ok');
    });

    test('retorna Failure quando test é false', () {
      final r = Result.cond(false, 'ok', 'erro');
      expect(r.isFailure, isTrue);
      expect(r.failureValue, 'erro');
    });
  });

  group('Result.condLazy', () {
    test('só avalia o lado correto', () {
      int calls = 0;
      Result.condLazy(
        true,
        () => 'ok',
        () {
          calls++;
          return 'erro';
        },
      );
      expect(calls, 0);
    });
  });

  group('Result.guard', () {
    test('retorna Success quando fn não lança', () {
      final r = Result.guard(() => 42, onError: (e) => 'erro: $e');
      expect(r.successValue, 42);
    });

    test('retorna Failure quando fn lança', () {
      final r = Result.guard<String, int>(
        () => throw Exception('boom'),
        onError: (e) => 'capturado',
      );
      expect(r.failureValue, 'capturado');
    });
  });

  group('Result.guardTyped', () {
    test('captura apenas o tipo especificado', () {
      final r = Result.guardTyped<FormatException, String, int>(
        () => int.parse('abc'),
        onError: (e) => 'formato inválido',
      );
      expect(r.failureValue, 'formato inválido');
    });

    test('deixa passar exceções de outro tipo', () {
      expect(
        () => Result.guardTyped<ArgumentError, String, int>(
          () => throw StateError('outro'),
          onError: (e) => 'não chega aqui',
        ),
        throwsStateError,
      );
    });
  });

  // ── fold ─────────────────────────────────────────────────────────────────

  group('fold', () {
    test('chama onSuccess em Success', () {
      final r = Result.success<String, int>(5);
      final out = r.fold((f) => 'falha', (s) => 'ok:$s');
      expect(out, 'ok:5');
    });

    test('chama onFailure em Failure', () {
      final r = Result.failure<String, int>('err');
      final out = r.fold((f) => 'falha:$f', (s) => 'ok');
      expect(out, 'falha:err');
    });
  });

  // ── map ──────────────────────────────────────────────────────────────────

  group('map', () {
    test('transforma Success', () {
      final r = Result.success<String, int>(3).map((n) => n * 2);
      expect(r.successValue, 6);
    });

    test('não aplica em Failure', () {
      final r = Result.failure<String, int>('err').map((n) => n * 2);
      expect(r.failureValue, 'err');
    });
  });

  group('mapFailure', () {
    test('transforma Failure', () {
      final r = Result.failure<int, String>(42).mapFailure((f) => 'erro $f');
      expect(r.failureValue, 'erro 42');
    });

    test('não aplica em Success', () {
      final r = Result.success<int, String>('ok').mapFailure((f) => f + 1);
      expect(r.successValue, 'ok');
    });
  });

  // ── then (flatMap) ────────────────────────────────────────────────────────

  group('then', () {
    test('encadeia Success → Success', () {
      final r = Result.success<String, int>(5)
          .then((n) => Result.success<String, int>(n + 1));
      expect(r.successValue, 6);
    });

    test('encadeia Success → Failure', () {
      final r = Result.success<String, int>(5)
          .then((_) => Result.failure<String, int>('parou'));
      expect(r.failureValue, 'parou');
    });

    test('Failure ignora then', () {
      int calls = 0;
      final r = Result.failure<String, int>('err').then((n) {
        calls++;
        return Result.success<String, int>(n);
      });
      expect(r.failureValue, 'err');
      expect(calls, 0);
    });
  });

  // ── either (bimap) ────────────────────────────────────────────────────────

  group('either', () {
    test('transforma ambos os lados — Success', () {
      final r = Result.success<String, int>(1)
          .either((f) => 'F:$f', (s) => 'S:$s');
      expect(r.successValue, 'S:1');
    });

    test('transforma ambos os lados — Failure', () {
      final r = Result.failure<String, int>('x')
          .either((f) => 'F:$f', (s) => 'S:$s');
      expect(r.failureValue, 'F:x');
    });
  });

  // ── swap ─────────────────────────────────────────────────────────────────

  group('swap', () {
    test('inverte Success em Failure', () {
      final r = Result.success<String, int>(99).swap();
      expect(r.isFailure, isTrue);
      expect(r.failureValue, 99);
    });

    test('inverte Failure em Success', () {
      final r = Result.failure<String, int>('err').swap();
      expect(r.isSuccess, isTrue);
      expect(r.successValue, 'err');
    });
  });

  // ── getOrElse / getOrCall / toNullable ───────────────────────────────────

  group('getOrElse', () {
    test('retorna valor em Success', () {
      expect(Result.success<String, int>(7).getOrElse(0), 7);
    });

    test('retorna default em Failure', () {
      expect(Result.failure<String, int>('err').getOrElse(0), 0);
    });
  });

  group('getOrCall', () {
    test('retorna valor em Success', () {
      expect(Result.success<String, int>(7).getOrCall((_) => 0), 7);
    });

    test('chama fn em Failure com o erro', () {
      final r = Result.failure<String, int>('falha');
      expect(r.getOrCall((f) => f.length), 5);
    });
  });

  group('toNullable', () {
    test('retorna valor em Success', () {
      expect(Result.success<String, int>(3).toNullable(), 3);
    });

    test('retorna null em Failure', () {
      expect(Result.failure<String, int>('err').toNullable(), isNull);
    });
  });

  // ── tap / tapFailure ─────────────────────────────────────────────────────

  group('tap / tapFailure', () {
    test('tap executa side-effect em Success', () {
      int seen = 0;
      final r = Result.success<String, int>(5).tap((v) => seen = v);
      expect(seen, 5);
      expect(r.successValue, 5);
    });

    test('tap não executa em Failure', () {
      int seen = 0;
      Result.failure<String, int>('err').tap((v) => seen = v);
      expect(seen, 0);
    });

    test('tapFailure executa side-effect em Failure', () {
      String seen = '';
      Result.failure<String, int>('err').tapFailure((f) => seen = f);
      expect(seen, 'err');
    });

    test('tapFailure não executa em Success', () {
      String seen = '';
      Result.success<String, int>(1).tapFailure((f) => seen = f);
      expect(seen, '');
    });
  });

  // ── recover ──────────────────────────────────────────────────────────────

  group('recover', () {
    test('converte Failure em Success', () {
      final r = Result.failure<String, int>('err').recover((f) => -1);
      expect(r.successValue, -1);
    });

    test('Success passa intacto', () {
      final r = Result.success<String, int>(5).recover((_) => -1);
      expect(r.successValue, 5);
    });
  });

  // ── equality ─────────────────────────────────────────────────────────────

  group('equality', () {
    test('dois Success com o mesmo valor são iguais', () {
      expect(Result.success<String, int>(1), equals(Result.success<String, int>(1)));
    });

    test('dois Failure com o mesmo erro são iguais', () {
      expect(
        Result.failure<String, int>('err'),
        equals(Result.failure<String, int>('err')),
      );
    });

    test('Success ≠ Failure com o mesmo valor', () {
      expect(
        Result.success<int, int>(1),
        isNot(equals(Result.failure<int, int>(1))),
      );
    });
  });

  // ── toString ─────────────────────────────────────────────────────────────

  group('toString', () {
    test('Success exibe valor', () {
      expect(Result.success<String, int>(42).toString(), 'Success(42)');
    });

    test('Failure exibe erro', () {
      expect(Result.failure<String, int>('oops').toString(), 'Failure(oops)');
    });
  });
}
