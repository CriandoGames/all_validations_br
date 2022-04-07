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

  test('Should call validation Checks if Phone BRAZIL', () {
    var sut = AllValidations.isPhoneNumber('947240687');
    expect(sut, true);

    sut = AllValidations.isPhoneNumber('897240687');
    expect(sut, true);

    sut = AllValidations.isPhoneNumber('21947240687');
    expect(sut, true);

    sut = AllValidations.isPhoneNumber('21 947240687');
    expect(sut, true);

    sut = AllValidations.isPhoneNumber('21 9 4724-0687');
    expect(sut, true);

    sut = AllValidations.isPhoneNumber('(21) 9 4724-0687');
    expect(sut, true);

    sut = AllValidations.isPhoneNumber('67640315093');
    expect(sut, true);

    sut = AllValidations.isPhoneNumber('(10) 9 9476-3908');
    expect(sut, false);

    sut = AllValidations.isPhoneNumber('01994763908');
    expect(sut, false);

    sut = AllValidations.isPhoneNumber('03582129012');
    expect(sut, false);

    
    ///numeros antigos com 8 digitos
    sut = AllValidations.isPhoneNumber('94724067');
    expect(sut, false);

    sut = AllValidations.isPhoneNumber('947240');
    expect(sut, false);
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
