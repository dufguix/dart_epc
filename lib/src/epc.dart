import "dart:convert" show utf8, latin1;
import "package:convert/convert.dart"
    show latin2, latin4, latinCyrillic, latinGreek, latin6, latin9;
import 'dart:typed_data';

import "enums.dart";
import "exceptions.dart";

/// European Payments Council
/// Check by yourself: The BIC will continue to be mandatory for SEPA payment transactions involving SCT scheme participants from non-EEA countries.
/// Throws: [EpcInvalidException] and [EpcTooLongException].
class Epc {
  factory Epc({
    String serviceTag = "BCD",
    Version version = Version.v2,
    CharSet characterSet = CharSet.utf8,
    String identification = "SCT",
    String bic = "",
    required String name,
    required String iban,
    String amount = "",
    String purpose = "",
    String remittanceRef = "",
    String remittanceText = "",
    String information = "",
    Separator separator = Separator.lf,
  }) {
    serviceTagCheck(serviceTag, true);
    identificationCheck(identification, true);
    bicCheck(bic, version, true);
    nameCheck(name, true);
    ibanCheck(iban, true);
    amountCheck(amount, true);
    purposeCheck(purpose, true);
    remittanceInfoCheck(remittanceRef, remittanceText, true);
    informationCheck(information, true);
    final epc = Epc._(
      serviceTag: serviceTag,
      version: version,
      characterSet: characterSet,
      identification: identification,
      bic: bic,
      name: name,
      iban: iban,
      amount: amount,
      purpose: purpose,
      remittanceRef: remittanceRef,
      remittanceText: remittanceText,
      information: information,
      separator: separator,
    );
    epc.uint8ListContent();

    return epc;
  }

  Epc._({
    required this.serviceTag,
    required this.version,
    required this.characterSet,
    required this.identification,
    required this.bic,
    required this.name,
    required this.iban,
    required this.amount,
    required this.purpose,
    required this.remittanceRef,
    required this.remittanceText,
    required this.information,
    required this.separator,
  });

  final String serviceTag;
  final Version version;
  final CharSet characterSet;
  final String identification; // SCT = SEPA Credit Transfer
  final String bic;
  final String name;
  final String iban;
  final String amount;
  final String purpose; //Purpose of the transfer
  final String remittanceRef; // (Structured) (ISO 11649 may be used)
  final String remittanceText; // (Unstructured)
  final String information; // Beneficiary to Originator note
  final Separator separator;

  /// Limitation: Dart strings are UTF16 encodings.
  /// This method will not check byte length.
  /// Use [uint8ListContent] for the right encoding.
  String stringContent() {
    return [
      serviceTag,
      version.value,
      characterSet.value,
      identification,
      bic,
      name,
      iban,
      "EUR$amount",
      purpose,
      remittanceRef,
      remittanceText,
      information
    ].join(separator.value);
  }

  /// Returns data with the right encoding.
  /// Throws [EpcTooLongException] if [maxBytes] is reached.
  Uint8List uint8ListContent() {
    final Uint8List bytes = switch (characterSet) {
      (CharSet.utf8) => utf8.encode(stringContent()),
      (CharSet.iso8859_1) => latin1.encode(stringContent()),
      (CharSet.iso8859_2) => latin2.encode(stringContent()),
      (CharSet.iso8859_4) => latin4.encode(stringContent()),
      (CharSet.iso8859_5) => latinCyrillic.encode(stringContent()),
      (CharSet.iso8859_7) => latinGreek.encode(stringContent()),
      (CharSet.iso8859_10) => latin6.encode(stringContent()),
      (CharSet.iso8859_15) => latin9.encode(stringContent()),
    };

    if (bytes.length > maxBytes) {
      throw EpcTooLongException(
          "The total payload is limited to $maxBytes bytes.");
    }

    return bytes;
  }

  static const serviceTagLength = 3;
  static const versionLength = 3;
  static const identificationLength = 3;
  static const bicMaxLength = 11;
  static const nameMaxLength = 70;
  static const ibanMaxLength = 34;
  static const amountMaxLength = 12;
  static final amountRegEx = RegExp(r'^\d+(?:\.\d{1,2})?$');
  static const purposeMaxLength = 4;
  static const remittanceRefMaxLength = 35;
  static const remittanceTextMaxLength = 140;
  static const informationMaxLength = 70;

  /// The total payload limitation in bytes (not chars). May vary depending on encoding.
  static const maxBytes = 331;

  static CheckResult serviceTagCheck(String val,
      [bool throwException = false]) {
    var result = CheckResult.pass;
    if (val.length != serviceTagLength) result = CheckResult.badLength;
    if (throwException && result != CheckResult.pass) {
      throw EpcInvalidException("$val: $result", result);
    }
    return result;
  }

  static CheckResult identificationCheck(String val,
      [bool throwException = false]) {
    var result = CheckResult.pass;
    if (val.length != identificationLength) result = CheckResult.badLength;
    if (throwException && result != CheckResult.pass) {
      throw EpcInvalidException("$val: $result", result);
    }
    return result;
  }

  /// Mandatory with V1
  /// Check by yourself: The BIC will continue to be mandatory for SEPA payment transactions involving SCT scheme participants from non-EEA countries.
  static CheckResult bicCheck(String val, Version version,
      [bool throwException = false]) {
    var result = CheckResult.pass;
    if (version == Version.v1 && val.isEmpty) result = CheckResult.mandatory;
    if (val.length > bicMaxLength) result = CheckResult.tooLong;
    if (throwException && result != CheckResult.pass) {
      throw EpcInvalidException("$val: $result", result);
    }
    return result;
  }

  static CheckResult nameCheck(String val, [bool throwException = false]) {
    var result = CheckResult.pass;
    if (val.isEmpty) result = CheckResult.mandatory;
    if (val.length > nameMaxLength) result = CheckResult.tooLong;
    if (throwException && result != CheckResult.pass) {
      throw EpcInvalidException("$val: $result", result);
    }
    return result;
  }

  static CheckResult ibanCheck(String val, [bool throwException = false]) {
    var result = CheckResult.pass;
    if (val.isEmpty) result = CheckResult.mandatory;
    if (val.length > ibanMaxLength) result = CheckResult.tooLong;
    if (throwException && result != CheckResult.pass) {
      throw EpcInvalidException("$val: $result", result);
    }
    return result;
  }

  /// Amount must be larger than or equal to 0.01, and cannot be larger than 999999999.99
  static CheckResult amountCheck(String val, [bool throwException = false]) {
    var result = CheckResult.pass;
    if (val.length > amountMaxLength) result = CheckResult.tooLong;
    if (val.isNotEmpty && !amountRegEx.hasMatch(val)) {
      result = CheckResult.badValue;
    }
    if (throwException && result != CheckResult.pass) {
      throw EpcInvalidException("$val: $result", result);
    }
    return result;
  }

  static CheckResult purposeCheck(String val, [bool throwException = false]) {
    var result = CheckResult.pass;
    if (val.length > purposeMaxLength) result = CheckResult.tooLong;
    if (throwException && result != CheckResult.pass) {
      throw EpcInvalidException("$val: $result", result);
    }
    return result;
  }

  static CheckResult remittanceInfoCheck(
      String remittanceRef, String remittanceText,
      [bool throwException = false]) {
    var result = CheckResult.pass;
    if (remittanceRef.isNotEmpty && remittanceText.isNotEmpty) {
      result = CheckResult.conflict;
    }
    if (remittanceRef.length > remittanceRefMaxLength) {
      result = CheckResult.tooLong;
    }
    if (remittanceText.length > remittanceTextMaxLength) {
      result = CheckResult.tooLong;
    }
    if (throwException && result != CheckResult.pass) {
      throw EpcInvalidException(
          "$remittanceRef, $remittanceText: $result", result);
    }
    return result;
  }

  static CheckResult informationCheck(String val,
      [bool throwException = false]) {
    var result = CheckResult.pass;
    if (val.length > informationMaxLength) result = CheckResult.tooLong;
    if (throwException && result != CheckResult.pass) {
      throw EpcInvalidException("$val: $result", result);
    }
    return result;
  }
}
