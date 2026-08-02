# Exemplo integrado

Aplicação Flutter que demonstra validações, máscara com `BrZod`, `Result`,
logging em memória, utilitários legados e criptografia autenticada por meio do
agregador `all_validations_br`.

A seção crypto usa `AllCrypto` e `CryptEnvelope` v2; a chave sintética permanece
somente em memória e nunca integra o envelope exibido.

A demonstração de atualização automática da saída criptográfica usa `all_observer` somente neste aplicativo. `Observable` e `Computed` vivem no controller, os `Observer`s são locais e todos os recursos são descartados. Essa dependência não faz parte de nenhum manifesto publicável do ecossistema.

```shell
flutter pub get
flutter analyze
flutter test
dart run custom_lint
flutter run
```

O exemplo usa dados sintéticos. Não registre nem copie chaves, documentos pessoais ou payloads de produção. Para dependências menores em aplicações novas, consulte a seleção de pacotes no README da raiz.
