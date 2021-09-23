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

  });
}
