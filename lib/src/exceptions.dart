import 'enums.dart';

class EpcInvalidException implements Exception {
  EpcInvalidException(this.message, this.result);
  String message;
  CheckResult result;
}

/// When the total payload exceeds [maxBytes] bytes.
class EpcTooLongException implements Exception {
  EpcTooLongException(this.message);
  String message;
}
