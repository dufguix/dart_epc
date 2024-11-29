import 'package:epc_qr_code/epc_qr_code.dart';
import 'package:test/test.dart';

void main() {
  group('Amount regex test', () {
    setUp(() {
      // Additional setup goes here.
    });

    test("'5' isTrue", () {
      expect(EpcValidator.amountRegEx.hasMatch("5"), isTrue);
    });

    test("'0.5' isTrue", () {
      expect(EpcValidator.amountRegEx.hasMatch("0.5"), isTrue);
    });

    test("'55.55' isTrue", () {
      expect(EpcValidator.amountRegEx.hasMatch("55.55"), isTrue);
    });

    test("'0.555' isFalse", () {
      expect(EpcValidator.amountRegEx.hasMatch("0.555"), isFalse);
    });

    test("'.5' isFalse", () {
      expect(EpcValidator.amountRegEx.hasMatch(".5"), isFalse);
    });

    test("' 5' isFalse", () {
      expect(EpcValidator.amountRegEx.hasMatch(" 5"), isFalse);
    });

    test("'5 ' isFalse", () {
      expect(EpcValidator.amountRegEx.hasMatch("5 "), isFalse);
    });

    test("'5..5' isFalse", () {
      expect(EpcValidator.amountRegEx.hasMatch("5..5"), isFalse);
    });

    test("'a5' isFalse", () {
      expect(EpcValidator.amountRegEx.hasMatch("a5"), isFalse);
    });
  });
}
