enum Version {
  v1("001"),
  v2("002");

  const Version(this.value);
  final String value;
}

enum CharSet {
  utf8("1"),
  iso8859_1("2"),
  iso8859_2("3"),
  iso8859_4("4"),
  iso8859_5("5"),
  iso8859_7("6"),
  iso8859_10("7"),
  iso8859_15("8");

  const CharSet(this.value);
  final String value;
}

enum Separator {
  lf("\n"),
  crLf("\r\n");

  const Separator(this.value);
  final String value;
}

enum CheckResult {
  /// Pass all test
  pass,

  /// Doesnt match expected length
  badLength,

  /// Exceed the maximum length
  tooLong,

  /// Can't be empty
  mandatory,

  /// Only one of the elements may be populated
  conflict,

  /// When doesn't match a regular expression
  badValue,
}
