import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Ambiente de teste', () {
    test('Validators é acessível e validateNome funciona', () {
      expect(Validators.validateNome('Maria'), isNull);
      expect(Validators.validateNome(''), isNotNull);
      expect(Validators.validateNome('Maria123'), isNotNull);
    });

    test('validateEmail funciona', () {
      expect(Validators.validateEmail('teste@email.com'), isNull);
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail('invalido'), isNotNull);
    });

    test('formatName funciona', () {
      expect(Validators.formatName('maria silva'), equals('Maria Silva'));
      expect(Validators.formatName(''), equals(''));
    });
  });
}
