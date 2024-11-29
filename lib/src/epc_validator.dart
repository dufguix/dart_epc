import '../epc_qr_code.dart';

abstract class EpcValidator {
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
