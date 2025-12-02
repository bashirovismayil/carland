extension StatusCodeExtension on int? {
  bool get isSuccess => this! > 199 && this! < 300;
  bool get isFailure => this! >= 400 && this! <= 500;
}