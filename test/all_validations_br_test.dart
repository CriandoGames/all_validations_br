import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should call validation Checks if data is null', () {
    var sut = AllValidations.isNull(null);
    expect(sut, true);
  });

  test('should call validation Checks if data is not null', () {
    var sut = AllValidations.isNull('');
    expect(sut, false);
  });

  test('should call validation Checks if is num', () {
    var sut = AllValidations.isNum('12345');
    expect(sut, true);
  });

  test('should call validation Checks if is not num', () {
    var sut = AllValidations.isNum('');
    expect(sut, false);
  });

  test('should call validation Checks if not is just number or double', () {
    var sut = AllValidations.isNumericOnly('');
    expect(sut, false);

    sut = AllValidations.isNumericOnly('1.1');
    expect(sut, false);

    sut = AllValidations.isNumericOnly('1aaa');
    expect(sut, false);

    sut = AllValidations.isNumericOnly('1.1a');
    expect(sut, false);
  });

  test('should call validation Checks if only number but double not work', () {
    var sut = AllValidations.isNumericOnly('1');
    expect(sut, true);
  });

  test('should call validation Checks if only Alphabet', () {
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

  test('should call validation Checks if string is bool format', () {
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

  test('should call validation Checks if string is float or int but ' ' error ',
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

  test('should call validation Checks if CEP BRAZIL', () {
    var sut = AllValidations.isValidBRZip('65092-276');
    expect(sut, true);

    sut = AllValidations.isValidBRZip('65092276');
    expect(sut, true);

    sut = AllValidations.isValidBRZip('650.922.76');
    expect(sut, false);

    sut = AllValidations.isValidBRZip('650.922.76');
    expect(sut, false);

    sut = AllValidations.isValidBRZip('650.922');
    expect(sut, false);
  });

  test('should call validation Checks if isVideo', () {
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

  test('should call validation Checks if isImage', () {
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

  test('should call validation Checks if formar RG ', () {
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

  test('should call validation Checks if formar CPF ', () {
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

  test('should call validation Checks if Phone BRAZIL', () {
    var sut = AllValidations.isPhoneNumber('947240687');
    expect(sut, true);

    sut = AllValidations.isPhoneNumber('21947240687');
    expect(sut, true);

    sut = AllValidations.isPhoneNumber('21 947240687');
    expect(sut, true);

    sut = AllValidations.isPhoneNumber('21 9 4724-0687');
    expect(sut, true);

    sut = AllValidations.isPhoneNumber('(21) 9 4724-0687');
    expect(sut, true);

    ///numeros antigos com 8 digitos
    sut = AllValidations.isPhoneNumber('94724067');
    expect(sut, false);

    sut = AllValidations.isPhoneNumber('947240');
    expect(sut, false);
  });

  test('should call validation Checks if num a EQUAL than num b.', () {
    var sut = AllValidations.isEqual(1, 1);
    expect(sut, true);

    sut = AllValidations.isEqual(2, 1);
    expect(sut, false);

    sut = AllValidations.isEqual(0, 0);
    expect(sut, true);
  });

  test('should call validation Checks if isLowerThan.', () {
    var sut = AllValidations.isLowerThan(1, 1);
    expect(sut, false);

    sut = AllValidations.isLowerThan(2, 1);
    expect(sut, false);

    sut = AllValidations.isLowerThan(1, 5);
    expect(sut, true);
  });

  test('should call validation Checks if isLowerThan.', () {
    var sut = AllValidations.isLowerThan(1, 1);
    expect(sut, false);

    sut = AllValidations.isLowerThan(2, 1);
    expect(sut, false);

    sut = AllValidations.isLowerThan(1, 5);
    expect(sut, true);
  });

  test('should call validation Checks if isGreaterThan.', () {
    var sut = AllValidations.isGreaterThan(1, 1);
    expect(sut, false);

    sut = AllValidations.isGreaterThan(2, 1);
    expect(sut, true);

    sut = AllValidations.isGreaterThan(1, 5);
    expect(sut, false);
  });

  test('should call validation Checks isInt.', () {
    var sut = AllValidations.isInt('1.1');
    expect(sut, false);

    sut = AllValidations.isInt('0');
    expect(sut, true);

    sut = AllValidations.isInt('1');
    expect(sut, true);
  });

  test('should call validation remove characters.', () {
    //(ex: `/`, `-`, `.`)
    String temp = '1-2/6.5';
    String resultTrue = '1265';

    var sut = AllValidations.removeCharacters(temp);
    expect(sut, resultTrue);
  });

  test('should call validation check if isLowercase.', () {
    var sut = AllValidations.isLowercase('aaaaaaa');
    expect(sut, true);

    sut = AllValidations.isLowercase('aaaaaaA');
    expect(sut, false);

    sut = AllValidations.isLowercase('AAAA');
    expect(sut, false);
  });

  test('should call validation check if isUppercase.', () {
    var sut = AllValidations.isUppercase('aaaaaaa');
    expect(sut, false);

    sut = AllValidations.isUppercase('aaaaaaA');
    expect(sut, false);

    sut = AllValidations.isUppercase('AAAA');
    expect(sut, true);
  });

  
}
