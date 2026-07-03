/// Result of [ServiceController.submitData].
class ServiceSubmitResult {
  final bool ok;
  final int statusCode;
  /// Non-empty when [ok] is true but attachments were omitted on a retry.
  final String infoMessage;
  /// Server / network error text when [ok] is false.
  final String errorMessage;

  const ServiceSubmitResult._({
    required this.ok,
    required this.statusCode,
    this.infoMessage = '',
    this.errorMessage = '',
  });

  factory ServiceSubmitResult.success({
    int statusCode = 200,
    String infoMessage = '',
  }) {
    return ServiceSubmitResult._(
      ok: true,
      statusCode: statusCode,
      infoMessage: infoMessage,
    );
  }

  factory ServiceSubmitResult.failure(int statusCode, String errorMessage) {
    return ServiceSubmitResult._(
      ok: false,
      statusCode: statusCode,
      errorMessage: errorMessage,
    );
  }
}
