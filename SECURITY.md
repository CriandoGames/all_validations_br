🇧🇷 Português | [🇺🇸 English](SECURITY.en.md)

# Política de segurança

A linha preparada é `4.6.x`; até sua publicação, a linha estável mais recente no pub.dev continua sendo a referência pública. O agregador reúne módulos com riscos diferentes; vulnerabilidades de criptografia devem mencionar `all_crypto`, e problemas de logging devem indicar se dados sensíveis foram expostos.

Reporte vulnerabilidades de forma privada pelo recurso **Security advisories**
do repositório, se habilitado, ou por outro canal privado confirmado diretamente
pelo mantenedor. Confirme que o canal está operacional antes da publicação.

Não abra issue pública com exploit, chave, token, CPF/CNPJ real, cartão ou payload de produção. Inclua versão, plataforma, impacto e reprodução mínima sanitizada. A equipe confirmará o recebimento e coordenará correção e divulgação; prazos dependem da severidade e da capacidade do mantenedor.

`HelperUtil.decodeJWT` apenas interpreta payloads e não autentica assinatura. O hash de senha legado em `HelperUtil` não deve ser adotado por sistemas novos. Use bibliotecas especializadas e algoritmos de derivação de senha adequados. Consulte também as políticas bilíngues de `all_crypto`.

O payload legado de crypto não tinha versão real e suas serializações incluíam
a própria chave. Use `AllCrypto`/`CryptEnvelope` v2 com chave externa para novos
dados. Os decoders `EncryptedPayload.fromJson`/`fromBase64` existem apenas para
migração; considere comprometida uma chave de payload legado que já circulou.

`HelperUtil.removeHtmlTags` não é sanitizador contra XSS. Os geradores legados com bits UUID v3/v5 usam um digest simplificado e não são interoperáveis com o algoritmo normativo MD5/SHA-1; use uma implementação especializada quando essa compatibilidade for necessária. Máscaras de PIX e documentos reduzem exposição visual, mas não anonimizam nem autorizam armazenamento de dados reais.
