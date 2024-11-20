import 'package:epc_qr_code/epc_qr_code.dart';
import 'package:test/test.dart';

void main() {
  // try {
  //   final epc = Epc(
  //       bic: "BPOTBEB1",
  //       name: "Red Cross",
  //       iban: "BE72000000001616",
  //       amount: "10",
  //       information: "Donation");
  // } on EpcInvalidException catch (e) {
  //   print(e.message);
  // } on EpcTooLongException catch (e) {
  //   print(e.message);
  // }

  group('EPC QR Code Library Tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Correct test', () {
      expect(
          () => Epc(
              bic: "BPOTBEB1",
              name: "Red Cross",
              iban: "BE72000000001616",
              amount: "10",
              information: "Donation"),
          returnsNormally);
    });

    test('Empty name throws exception', () {
      expect(
          () => Epc(
              bic: "BPOTBEB1",
              name: "",
              iban: "BE72000000001616",
              amount: "10",
              information: "Donation"),
          throwsA(TypeMatcher<EpcInvalidException>()));
    });

    test('Empty iban throws exception', () {
      expect(
          () => Epc(
              bic: "BPOTBEB1",
              name: "Red Cross",
              iban: "",
              amount: "10",
              information: "Donation"),
          throwsA(TypeMatcher<EpcInvalidException>()));
    });

    test('Empty bic with V1 throws exception', () {
      expect(
          () => Epc(
              version: Version.v1,
              bic: "",
              name: "Red Cross",
              iban: "BE72000000001616",
              amount: "10",
              information: "Donation"),
          throwsA(TypeMatcher<EpcInvalidException>()));
    });

    test('remittance Ref and Text throws exception', () {
      expect(
          () => Epc(
              bic: "BPOTBEB1",
              name: "Red Cross",
              iban: "BE72000000001616",
              amount: "10",
              remittanceRef: "ref",
              remittanceText: "text",
              information: "Donation"),
          throwsA(TypeMatcher<EpcInvalidException>()));
    });

    test('check length with UTF8', () {
      final epc = Epc(
          bic: "BPOTBEB1",
          name: "Red Cross",
          iban: "BE72000000001616",
          amount: "1000000",
          information: "Une sacrée donation");
      expect(epc.stringContent().length, 83);
      expect(epc.uint8ListContent().length, 84);
    });
  });
}
