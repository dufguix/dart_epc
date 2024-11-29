import "dart:convert" show utf8, latin1, json;

import "package:convert/convert.dart"
    show latin2, latin4, latinCyrillic, latinGreek, latin6, latin9;
import 'dart:typed_data';

import "enums.dart";
import "epc_validator.dart";
import "exceptions.dart";

/// Factory with validation process.
/// Check by yourself: Iban format/checksum. And the BIC will continue to be mandatory for SEPA payment transactions involving SCT scheme participants from non-EEA countries.
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
    EpcValidator.serviceTagCheck(serviceTag, true);
    EpcValidator.identificationCheck(identification, true);
    EpcValidator.bicCheck(bic, version, true);
    EpcValidator.ibanCheck(iban, true);
    EpcValidator.nameCheck(name, true);
    EpcValidator.amountCheck(amount, true);
    EpcValidator.purposeCheck(purpose, true);
    EpcValidator.remittanceInfoCheck(remittanceRef, remittanceText, true);
    EpcValidator.informationCheck(information, true);
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

  /// The total payload limitation in bytes (not chars). May vary depending on encoding.
  static const maxBytes = 331;

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

  /// Use the [Epc] factory with validation process. Refer to it for exceptions.
  Epc copyWith({
    String? serviceTag,
    Version? version,
    CharSet? characterSet,
    String? bic,
    String? name,
    String? iban,
    String? amount,
    String? purpose,
    String? remittanceRef,
    String? remittanceText,
    String? information,
    Separator? separator,
  }) {
    return Epc(
      serviceTag: serviceTag ?? this.serviceTag,
      version: version ?? this.version,
      characterSet: characterSet ?? this.characterSet,
      bic: bic ?? this.bic,
      name: name ?? this.name,
      iban: iban ?? this.iban,
      amount: amount ?? this.amount,
      purpose: purpose ?? this.purpose,
      remittanceRef: remittanceRef ?? this.remittanceRef,
      remittanceText: remittanceText ?? this.remittanceText,
      information: information ?? this.information,
      separator: separator ?? this.separator,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'serviceTag': serviceTag,
      'version': version.name,
      'characterSet': characterSet.name,
      'bic': bic,
      'name': name,
      'iban': iban,
      'amount': amount,
      'purpose': purpose,
      'remittanceRef': remittanceRef,
      'remittanceText': remittanceText,
      'information': information,
      'separator': separator.name,
    };
  }

  factory Epc.fromMap(Map<String, dynamic> map) {
    return Epc(
      serviceTag: map['serviceTag'] as String,
      version: Version.values.byName(map['version']),
      characterSet: CharSet.values.byName(map['characterSet']),
      bic: map['bic'] as String,
      name: map['name'] as String,
      iban: map['iban'] as String,
      amount: map['amount'] as String,
      purpose: map['purpose'] as String,
      remittanceRef: map['remittanceRef'] as String,
      remittanceText: map['remittanceText'] as String,
      information: map['information'] as String,
      separator: Separator.values.byName(map['separator']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Epc.fromJson(String source) =>
      Epc.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Epc(serviceTag: $serviceTag, version: $version, characterSet: $characterSet, bic: $bic, name: $name, iban: $iban, amount: $amount, purpose: $purpose, remittanceRef: $remittanceRef, remittanceText: $remittanceText, information: $information, separator: $separator)';
  }

  @override
  bool operator ==(covariant Epc other) {
    if (identical(this, other)) return true;

    return other.serviceTag == serviceTag &&
        other.version == version &&
        other.characterSet == characterSet &&
        other.bic == bic &&
        other.name == name &&
        other.iban == iban &&
        other.amount == amount &&
        other.purpose == purpose &&
        other.remittanceRef == remittanceRef &&
        other.remittanceText == remittanceText &&
        other.information == information &&
        other.separator == separator;
  }

  @override
  int get hashCode {
    return serviceTag.hashCode ^
        version.hashCode ^
        characterSet.hashCode ^
        bic.hashCode ^
        name.hashCode ^
        iban.hashCode ^
        amount.hashCode ^
        purpose.hashCode ^
        remittanceRef.hashCode ^
        remittanceText.hashCode ^
        information.hashCode ^
        separator.hashCode;
  }
}
