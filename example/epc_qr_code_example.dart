import 'package:epc_qr_code/epc_qr_code.dart';

void main() {
  try {
    final epc = Epc(
        bic: "BPOTBEB1",
        name: "Red Cross",
        iban: "BE72000000001616",
        amount: "10",
        information: "Donation");
    print(epc.stringContent());
  } on EpcInvalidException catch (e) {
    print(e.message); // One field doesn't pass its checker.
  } on EpcTooLongException catch (e) {
    print(e.message); // Total payload is too long.
  }

  // Create your qr code with a third party lib.
  // final qrCode = QrCode.fromUint8List(epc.uint8ListContent(), QrErrorCorrectLevel.M);
}
