# Contribuindo com o All Validations BR

Ficamos felizes que você queira contribuir! Sua ajuda é fundamental para manter e evoluir esta biblioteca.

Contribuições feitas aqui são publicadas sob a [licença MIT](LICENSE) do projeto.

Ao participar, você concorda em seguir nosso [Código de Conduta](CODE_OF_CONDUCT.md).

---

## Como contribuir

### Reportando bugs ou sugerindo melhorias

Abra uma [Issue](https://github.com/CriandoGames/all_validations_br/issues/new) descrevendo:

- O que aconteceu e o que era esperado
- Versão da biblioteca e do Flutter/Dart
- Trecho de código que reproduz o problema (se aplicável)

### Enviando um Pull Request

1. Faça um fork do repositório e clone localmente
2. Crie um branch a partir da `main`: `git checkout -b minha-feature`
3. Instale as dependências: `flutter pub get`
4. Faça sua alteração
5. Garanta que os testes passam: `flutter test`
6. Faça commit com uma mensagem clara (veja abaixo)
7. Envie para seu fork e abra um Pull Request

---

## Padrões do projeto

- **Idioma do código:** inglês (nomes de variáveis, métodos, classes)
- **Idioma dos comentários e docs:** português ou inglês são aceitos
- **Estilo:** siga o `analysis_options.yaml` do projeto — rode `flutter analyze` antes de abrir o PR
- **Testes:** toda nova validação ou utilitário deve ter testes em `test/`
- **Foco:** mantenha o PR pequeno e com um único objetivo; mudanças independentes devem ir em PRs separados

---

## Boas mensagens de commit

```
feat: adiciona validação de CNS
fix: corrige cálculo do dígito verificador do PIS
test: adiciona testes para BrData.parseWithTime
docs: atualiza exemplos de CryptUtil no README
```

Use o prefixo: `feat`, `fix`, `test`, `docs`, `refactor` ou `chore`.

---

## Rodando os testes

```bash
flutter test
```

Para um arquivo específico:

```bash
flutter test test/cpf_test.dart
```

---

## Dúvidas?

Abra uma [Issue](https://github.com/CriandoGames/all_validations_br/issues) com sua pergunta. Respondemos o mais breve possível.
