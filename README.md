# Dart lib for EPC QR code

> The European Payments Council Quick Response Code guidelines define the content of a QR code that can be used to initiate SEPA credit transfer (SCT). - [Wikipedia](https://en.wikipedia.org/wiki/EPC_QR_code)

In short, this lib generates the string to insert into a QR code.
Use another lib to create the QR code.
Then user can scan the QR code with his/her banking app.

This lib is following this [guide](https://www.europeanpaymentscouncil.eu/sites/default/files/kb/file/2022-09/EPC069-12%20v3.0%20Quick%20Response%20Code%20-%20Guidelines%20to%20Enable%20the%20Data%20Capture%20for%20the%20Initiation%20of%20an%20SCT_0.pdf).

## Limitations:
- Iban is not checked. But you can use [iban lib](https://pub.dev/packages/iban).
- Non-EEA countries are not checked. The BIC field is mandatory for SEPA payment transactions involving participants from non-EEA countries.

## Usage

```dart
import 'package:epc_qr_code/epc_qr_code.dart';
import 'package:qr/qr.dart';

final epc = Epc(
      bic: "BPOTBEB1",
      name: "Red Cross",
      iban: "BE72000000001616",
      amount: "10",
      information: "Donation");


final qrCode = QrCode.fromUint8List(epc.uint8ListContent(), QrErrorCorrectLevel.M);
```

Prefer `epc.uint8ListContent()` over `epc.stringContent()`. Dart string are utf16.
