import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Should call validation Checks if data is null', () {
    var sut = AllValidations.isNull(null);
    expect(sut, true);
  });

  test('Should call validation Checks if data is not null', () {
    var sut = AllValidations.isNull('');
    expect(sut, false);
  });

  test('Should call validation Checks if is num', () {
    var sut = AllValidations.isNum('12345');
    expect(sut, true);
  });

  test('Should call validation Checks if is not num', () {
    var sut = AllValidations.isNum('');
    expect(sut, false);
  });

  test('Should call validation Checks if not is just number or double', () {
    var sut = AllValidations.isNumericOnly('');
    expect(sut, false);

    sut = AllValidations.isNumericOnly('1.1');
    expect(sut, false);

    sut = AllValidations.isNumericOnly('1aaa');
    expect(sut, false);

    sut = AllValidations.isNumericOnly('1.1a');
    expect(sut, false);
  });

  test('Should call validation Checks if only number but double not work', () {
    var sut = AllValidations.isNumericOnly('1');
    expect(sut, true);
  });

  test('Should call validation Checks if only Alphabet', () {
    var sut = AllValidations.isAlphabetOnly('');
    expect(sut, false);

    sut = AllValidations.isAlphabetOnly('1.1');
    expect(sut, false);

    sut = AllValidations.isAlphabetOnly('1aaa');
    expect(sut, false);

    sut = AllValidations.isAlphabetOnly('1.1a');
    expect(sut, false);

    sut = AllValidations.isAlphabetOnly('aaaaaa');
    expect(sut, true);
  });

  test('Should call validation Checks if string is bool format', () {
    var sut = AllValidations.isBool('');
    expect(sut, false);

    sut = AllValidations.isBool('1');
    expect(sut, false);

    sut = AllValidations.isBool('aaa');
    expect(sut, false);

    sut = AllValidations.isBool('1.1');
    expect(sut, false);

    sut = AllValidations.isBool('true');
    expect(sut, true);

    sut = AllValidations.isBool('false');
    expect(sut, true);
  });

  test('Should call validation Checks if string is float or int but ' ' error ',
      () {
    var sut = AllValidations.isNumericFloat('1.1');
    expect(sut, true);

    sut = AllValidations.isNumericFloat('1');
    expect(sut, true);

    sut = AllValidations.isNumericFloat('aaaaa');
    expect(sut, false);

    sut = AllValidations.isNumericFloat('aaa3234234aa');
    expect(sut, false);

    sut = AllValidations.isNumericFloat('dasd5345!!!#');
    expect(sut, false);
  });

  test('Should call validation Checks if CEP BRAZIL', () {
    var sut = AllValidations.isValidBRZip('65092-276');
    expect(sut, true);

    sut = AllValidations.isValidBRZip('65092276');
    expect(sut, true);

    sut = AllValidations.isValidBRZip('65.092-276');
    expect(sut, true);

    sut = AllValidations.isValidBRZip('650.922.76');
    expect(sut, false);

    sut = AllValidations.isValidBRZip('650.922.76');
    expect(sut, false);

    sut = AllValidations.isValidBRZip('650.922');
    expect(sut, false);

    sut = AllValidations.isValidBRZip('65');
    expect(sut, false);

    sut = AllValidations.isValidBRZip('6ç.321-321');
    expect(sut, false);

    sut = AllValidations.isValidBRZip('62.6321-3261');
    expect(sut, false);

    sut = AllValidations.isValidBRZip('1234567');
    expect(sut, false);

    sut = AllValidations.isValidBRZip('12345678910');
    expect(sut, false);
  });

  test('Should call validation Checks if isVideo', () {
    var sut = AllValidations.isVideo('a.mp4');
    expect(sut, true);

    sut = AllValidations.isVideo('a.wmv');
    expect(sut, true);

    sut = AllValidations.isVideo('a.mpg');
    expect(sut, true);

    sut = AllValidations.isVideo('a.3gp');
    expect(sut, true);

    sut = AllValidations.isVideo('a.m4v');
    expect(sut, true);

    sut = AllValidations.isVideo('a.mgv');
    expect(sut, true);

    sut = AllValidations.isVideo('a.mov');
    expect(sut, true);

    sut = AllValidations.isVideo('a.mkv');
    expect(sut, true);

    sut = AllValidations.isVideo('a.ogv');
    expect(sut, true);

    sut = AllValidations.isVideo('a.qtm');
    expect(sut, true);

    sut = AllValidations.isVideo('a.srt');
    expect(sut, true);

    sut = AllValidations.isVideo('a.amc');
    expect(sut, true);

    sut = AllValidations.isVideo('a.dvx');
    expect(sut, true);

    sut = AllValidations.isVideo('a.flv');
    expect(sut, true);

    sut = AllValidations.isVideo('a.evo');
    expect(sut, true);

    sut = AllValidations.isVideo('a.avi');
    expect(sut, true);

    sut = AllValidations.isVideo('a.rmvb');
    expect(sut, true);

    sut = AllValidations.isVideo('a.mpg');
    expect(sut, true);

    sut = AllValidations.isVideo('a.mpeg');
    expect(sut, true);

    sut = AllValidations.isVideo('a.mp3');
    expect(sut, false);

    sut = AllValidations.isVideo('a');
    expect(sut, false);

    sut = AllValidations.isVideo('1');
    expect(sut, false);

    sut = AllValidations.isVideo('');
    expect(sut, false);

    sut = AllValidations.isVideo('.mp 4');
    expect(sut, false);

    sut = AllValidations.isVideo('.mP4');
    expect(sut, true);

    sut = AllValidations.isVideo(0x00.toString());
    expect(sut, false);

    sut = AllValidations.isVideo('\'.mp4');
    expect(sut, true);

    sut = AllValidations.isVideo('\/.mp4');
    expect(sut, true);
  });

  test('Should call validation Checks if isImage', () {
    var sut = AllValidations.isImage(".jpg");
    expect(sut, true);

    sut = AllValidations.isImage(".jpeg");
    expect(sut, true);

    sut = AllValidations.isImage(".png");
    expect(sut, true);

    sut = AllValidations.isImage(".gif");
    expect(sut, true);

    sut = AllValidations.isImage(".ico");
    expect(sut, true);

    sut = AllValidations.isImage(".svg");
    expect(sut, true);

    sut = AllValidations.isImage(".raw");
    expect(sut, true);

    sut = AllValidations.isImage(".bmp");
    expect(sut, true);

    sut = AllValidations.isImage('');
    expect(sut, false);

    sut = AllValidations.isImage('1');
    expect(sut, false);

    sut = AllValidations.isImage('A');
    expect(sut, false);

    sut = AllValidations.isImage('.');
    expect(sut, false);
  });

  test('Should call validation Checks if formar RG ', () {
    //RG gerado com https://www.4devs.com.br/gerador_de_rg
    var sut = AllValidations.isRG('222733822');
    expect(sut, true);

    sut = AllValidations.isRG('29.385.462-2');
    expect(sut, true);

    sut = AllValidations.isRG('65092276');
    expect(sut, true);

    sut = AllValidations.isRG('992.864.791-74');
    expect(sut, false);

    sut = AllValidations.isRG('1111');
    expect(sut, false);

    sut = AllValidations.isRG('aaaaa');
    expect(sut, false);
  });

  test('Should call validation Checks if formar CPF ', () {
    //RG gerado com https://www.4devs.com.br/gerador_de_rg
    var sut = AllValidations.isCpf('222733822');
    expect(sut, false);

    sut = AllValidations.isCpf('29.385.462-2');
    expect(sut, false);

    sut = AllValidations.isCpf('65092276');
    expect(sut, false);

    sut = AllValidations.isCpf('992.864.791-74');
    expect(sut, true);

    sut = AllValidations.isCpf('99286479174');
    expect(sut, true);

    sut = AllValidations.isCpf('1111');
    expect(sut, false);

    sut = AllValidations.isCpf('aaaaa');
    expect(sut, false);
  });

  group('Validação de DDDs Brasileiros', () {
    test('DDDs válidos', () {
      expect(AllValidations.isValidDDD("11"), true); // São Paulo
      expect(AllValidations.isValidDDD("21"), true); // Rio de Janeiro
      expect(AllValidations.isValidDDD("31"), true); // Belo Horizonte
      expect(AllValidations.isValidDDD("61"), true); // Brasília
      expect(AllValidations.isValidDDD("71"), true); // Salvador
      expect(AllValidations.isValidDDD("81"), true); // Recife
      expect(AllValidations.isValidDDD("91"), true); // Belém
      expect(AllValidations.isValidDDD("99"), true); // Maranhão
      expect(AllValidations.isValidDDD("51"), true); // Porto Alegre
      expect(AllValidations.isValidDDD("41"), true); // Curitiba
    });

    test('DDDs inválidos', () {
      expect(AllValidations.isValidDDD("00"), false); // Não existe DDD 00
      expect(AllValidations.isValidDDD("1"), false); // DDD incompleto
      expect(AllValidations.isValidDDD("123"),
          false); // Número com mais de 2 dígitos
      expect(AllValidations.isValidDDD("10"), false); // Não existe DDD 10
      expect(AllValidations.isValidDDD("00"), false); // Não existe DDD 00
      expect(AllValidations.isValidDDD("67a"),
          false); // Contém caracteres não numéricos
      expect(AllValidations.isValidDDD(""), false); // String vazia
      expect(AllValidations.isValidDDD("abc"), false); // Não numérico
      expect(AllValidations.isValidDDD("55"), true);
      expect(AllValidations.isValidDDD("80"), false); // Não existe DDD 80
    });
  });
  group('Validação de Celulares Brasileiros', () {
    test('Números de celular válidos', () {
      expect(AllValidations.isBrazilianCellPhone("(11) 91234-5678"), true);
      expect(AllValidations.isBrazilianCellPhone("11 91234-5678"), true);
      expect(AllValidations.isBrazilianCellPhone("+55 11 91234-5678"), true);
      expect(AllValidations.isBrazilianCellPhone("11912345678"), true);
      expect(AllValidations.isBrazilianCellPhone("(21) 98765-4321"), true);
      expect(AllValidations.isBrazilianCellPhone("+55 21 98765-4321"), true);
      expect(AllValidations.isBrazilianCellPhone("21987654321"), true);
      expect(AllValidations.isBrazilianCellPhone("(31) 99123-4567"), true);
      expect(AllValidations.isBrazilianCellPhone("31 99123-4567"), true);
      expect(AllValidations.isBrazilianCellPhone("32991234567"), true);
    });

    test('Números de celular inválidos', () {
      expect(AllValidations.isBrazilianCellPhone(""), false); // Vazio
      expect(AllValidations.isBrazilianCellPhone("11 1234-5678"),
          false); // Fixo, não celular
      expect(AllValidations.isBrazilianCellPhone("(11) 91234"),
          false); // Incompleto
      expect(AllValidations.isBrazilianCellPhone("+55 11 91234-567"),
          false); // Incompleto
      expect(
          AllValidations.isBrazilianCellPhone("991234567"), false); // Sem DDD
      expect(AllValidations.isBrazilianCellPhone("1198123456"),
          false); // Tamanho inválido
      expect(AllValidations.isBrazilianCellPhone("(21) 81234-5678"),
          false); // Não começa com 9
      expect(AllValidations.isBrazilianCellPhone("+55 01 91234-5678"),
          false); // DDD inválido
      expect(AllValidations.isBrazilianCellPhone("213812345678"),
          false); // Número muito longo
      expect(AllValidations.isBrazilianCellPhone("texto inválido"),
          false); // Não é número
    });
  });

  group('Validação de Telefones Fixos Brasileiros', () {
    test('Números fixos válidos', () {
      expect(AllValidations.isBrazilianLandline("(11) 2345-6789"), true);
      expect(AllValidations.isBrazilianLandline("11 2345-6789"), true);
      expect(AllValidations.isBrazilianLandline("+55 11 2345-6789"), true);
      expect(AllValidations.isBrazilianLandline("1123456789"), true);
      expect(AllValidations.isBrazilianLandline("(21) 3456-7890"), true);
      expect(AllValidations.isBrazilianLandline("+55 21 3456-7890"), true);
      expect(AllValidations.isBrazilianLandline("2134567890"), true);
      expect(AllValidations.isBrazilianLandline("(31) 4455-6677"), true);
      expect(AllValidations.isBrazilianLandline("31 4455-6677"), true);
      expect(AllValidations.isBrazilianLandline("8142234455"), true);
    });

    test('Números fixos inválidos', () {
      expect(AllValidations.isBrazilianLandline(""), false); // Vazio
      expect(AllValidations.isBrazilianLandline("11 91234-5678"),
          false); // Celular, não fixo
      expect(
          AllValidations.isBrazilianLandline("(11) 234"), false); // Incompleto
      expect(AllValidations.isBrazilianLandline("+55 11 2345-678"),
          false); // Incompleto
      expect(AllValidations.isBrazilianLandline("123456789"), false); // Sem DDD
      expect(AllValidations.isBrazilianLandline("11345678"),
          false); // Tamanho inválido
      expect(AllValidations.isBrazilianLandline("(21) 1456-7890"),
          false); // Prefixo inválido
      expect(AllValidations.isBrazilianLandline("+55 01 3456-7890"),
          false); // DDD inválido
      expect(AllValidations.isBrazilianLandline("213456789012"),
          false); // Número muito longo
      expect(AllValidations.isBrazilianLandline("texto inválido"),
          false); // Não é número
    });
  });

  test('Should call validation Checks if num a EQUAL than num b.', () {
    var sut = AllValidations.isEqual(1, 1);
    expect(sut, true);

    sut = AllValidations.isEqual(2, 1);
    expect(sut, false);

    sut = AllValidations.isEqual(0, 0);
    expect(sut, true);
  });

  test('Should call validation Checks if isLowerThan.', () {
    var sut = AllValidations.isLowerThan(1, 1);
    expect(sut, false);

    sut = AllValidations.isLowerThan(2, 1);
    expect(sut, false);

    sut = AllValidations.isLowerThan(1, 5);
    expect(sut, true);
  });

  test('Should call validation Checks if isGreaterThan.', () {
    var sut = AllValidations.isGreaterThan(1, 1);
    expect(sut, false);

    sut = AllValidations.isGreaterThan(2, 1);
    expect(sut, true);

    sut = AllValidations.isGreaterThan(1, 5);
    expect(sut, false);
  });

  test('Should call validation Checks isInt.', () {
    var sut = AllValidations.isInt('1.1');
    expect(sut, false);

    sut = AllValidations.isInt('0');
    expect(sut, true);

    sut = AllValidations.isInt('1');
    expect(sut, true);
  });

  test('Should call validation remove characters.', () {
    //(ex: `/`, `-`, `.`)
    String temp = '1-2/6.5';
    String resultTrue = '1265';

    var sut = AllValidations.removeCharacters(temp);
    expect(sut, resultTrue);
  });

  test('Should call validation check if isLowercase.', () {
    var sut = AllValidations.isLowercase('aaaaaaa');
    expect(sut, true);

    sut = AllValidations.isLowercase('aaaaaaA');
    expect(sut, false);

    sut = AllValidations.isLowercase('AAAA');
    expect(sut, false);
  });

  test('Should call validation check if isUppercase.', () {
    var sut = AllValidations.isUppercase('aaaaaaa');
    expect(sut, false);

    sut = AllValidations.isUppercase('aaaaaaA');
    expect(sut, false);

    sut = AllValidations.isUppercase('AAAA');
    expect(sut, true);
  });

  test('Should call validation check if isUUID.', () {
    var sut = AllValidations.isUUID('edf06bf4-2c10-11ec-8d3d-0242ac130003');
    expect(sut, true);

    sut = AllValidations.isUUID('7b1e3188-e526-47ec-b7b8-fe390a1a2bee');
    expect(sut, true);

    sut = AllValidations.isUUID('a3bb189e-8bf9-3888-9912-ace4e6543002');
    expect(sut, true);

    sut = AllValidations.isUUID('a6edc906-2f9f-5fb2-a373-efac406f0ef2');
    expect(sut, true);

    sut = AllValidations.isUUID('a6edc906');
    expect(sut, false);

    sut = AllValidations.isUUID('aaaaaaaa');
    expect(sut, false);

    sut = AllValidations.isUUID('aaaaa423423aaa');
    expect(sut, false);
  });

  test('Should be check if is Email valide or not ', () {
    var sut = AllValidations.isEmail('história@historia.com');

    expect(sut, false);

    sut = AllValidations.isEmail('história@historia');
    expect(sut, false);

    sut = AllValidations.isEmail('histó');
    expect(sut, false);

    sut = AllValidations.isEmail('história@história');
    expect(sut, false);

    sut = AllValidations.isEmail('historia@historia');
    expect(sut, false);

    sut = AllValidations.isEmail('a@b.c.d.e.f');
    expect(sut, false);

    sut = AllValidations.isEmail('      ');
    expect(sut, false);

    sut = AllValidations.isEmail('a.c.d');
    expect(sut, false);

    sut = AllValidations.isEmail('abc');
    expect(sut, false);

    sut = AllValidations.isEmail('carloscastrogames@gmail.com');
    expect(sut, true);

    sut = AllValidations.isEmail('carloscastrogames@live.com');
    expect(sut, true);

    sut = AllValidations.isEmail('carloscastrogames@org.com');
    expect(sut, true);

    sut = AllValidations.isEmail('carloscastrogames@loja.com');
    expect(sut, true);

    sut = AllValidations.isEmail('carloscastrogames@loja.com.br');
    expect(sut, true);
  });

  test('Should call validation checks of Nickname', () {
    var sut = AllValidations.isNickname('CriandoGames');
    expect(sut, true);

    sut = AllValidations.isNickname('Criando_games');
    expect(sut, true);

    sut = AllValidations.isNickname('criando_games');
    expect(sut, true);

    sut = AllValidations.isNickname('Criando games');
    expect(sut, false);

    sut = AllValidations.isNickname('Cr');
    expect(sut, false);

    sut = AllValidations.isNickname('Criando-games');
    expect(sut, false);
  });

  test('Should be check if password if medium', () {
    var sut = AllValidations.isMediumPassword('123456789');
    expect(sut, false);

    sut = AllValidations.isMediumPassword('aaaaa');
    expect(sut, false);

    sut = AllValidations.isMediumPassword('dkjashdkjashldk');
    expect(sut, false);

    sut = AllValidations.isMediumPassword('123456789a');
    expect(sut, true);

    sut = AllValidations.isMediumPassword('123456789aA');
    expect(sut, true);

    sut = AllValidations.isMediumPassword('123456789aA1');
    expect(sut, true);

    sut = AllValidations.isMediumPassword('123456789aA1@');
    expect(sut, true);
  });

  test('Should be check if password if Strong', () {
    var sut = AllValidations.isStrongPassword('123456789');
    expect(sut, false);

    sut = AllValidations.isStrongPassword('aaaaa');
    expect(sut, false);

    sut = AllValidations.isStrongPassword('dkjashdkjashldk');
    expect(sut, false);

    sut = AllValidations.isStrongPassword('123456789a');
    expect(sut, false);

    sut = AllValidations.isStrongPassword('123456789aA');

    sut = AllValidations.isStrongPassword('123456789aA1');
    expect(sut, false);

    sut = AllValidations.isStrongPassword('123456789aA1@');
    expect(sut, true);
  });

  test('Should call validation checks of Palindrome', () {
    var sut = AllValidations.isPalindrome('Ana');
    expect(sut, true);

    sut = AllValidations.isPalindrome('Subi no onibus');
    expect(sut, true);

    sut = AllValidations.isPalindrome('a;;;;;;a...,.,.');
    expect(sut, true);

    sut = AllValidations.isPalindrome('22022022');
    expect(sut, true);

    sut = AllValidations.isPalindrome(
        'Luza Rocelina, a namorada do Manuel, leu na moda da romana: "anil é cor azul".');
    expect(sut, true);

    sut = AllValidations.isPalindrome('Criando games');
    expect(sut, false);

    sut = AllValidations.isPalindrome('Criando');
    expect(sut, false);

    sut = AllValidations.isPalindrome('123456');
    expect(sut, false);
  });

  test('Should call validation remove accents.', () {
    var sut = AllValidations.removeAccents('áêíôú');
    expect(sut, 'aeiou');

    sut = AllValidations.removeAccents('aeiou');
    expect(sut, 'aeiou');

    sut = AllValidations.removeAccents('2');
    expect(sut, '2');

    sut = AllValidations.removeAccents('');
    expect(sut, '');

    sut = AllValidations.removeAccents(' ');
    expect(sut, ' ');

    sut =
        AllValidations.removeAccents('você, Antônio, fêmea, gênio, acadêmico');
    expect(sut, 'voce, Antonio, femea, genio, academico');

    sut = AllValidations.removeAccents('maçã, coração, limão, benção, fusão');
    expect(sut, 'maca, coracao, limao, bencao, fusao');
    sut = AllValidations.removeAccents(
        'Vou à escola; Ele se referiu à planície; Vou à Bahia');
    expect(sut, 'Vou a escola; Ele se referiu a planicie; Vou a Bahia');
  });

  test('Should be check if pharse is equal for send service', () {
    var sut = AllValidations.isPhraseEqual('123456789', '123456789');
    expect(sut, true);

    sut = AllValidations.isPhraseEqual('123456789', '123456789a');
    expect(sut, false);

    sut = AllValidations.isPhraseEqual('123456789', '123456789aA');
    expect(sut, false);

    sut = AllValidations.isPhraseEqual('123456789', '123456789aA1');
    expect(sut, false);

    sut = AllValidations.isPhraseEqual('123456789', '123456789aA1@');

    expect(sut, false);
  });

  test('Should be check if map exists', () {
    Map map1 = {"status": "success", "message": "successfully logged out"};

    final sut =
        AllValidations.isMapExists(map: map1, key: ['status', 'message']);

    expect(sut, true);
  });

  test('Should be check if map no exists', () {
    Map map1 = {"status": "success", "message": "successfully logged out"};

    final sut = AllValidations.isMapExists(map: map1, key: ['error']);

    expect(sut, false);
  });

  test('Should be check if name is valid', () {
    var sut = AllValidations.isName('Teste');
    expect(sut, true);

    sut = AllValidations.isName('Çiçà');
    expect(sut, true);

    sut = AllValidations.isName('Ç1çà');
    expect(sut, false);

    sut = AllValidations.isName('Çiç@');
    expect(sut, false);
  });
}
