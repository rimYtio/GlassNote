import '../entities/ai_config.dart';

class AiConnectionTestResult {
  const AiConnectionTestResult._({
    required this.success,
    required this.message,
  });

  const AiConnectionTestResult.success(String message)
    : this._(success: true, message: message);

  const AiConnectionTestResult.failure(String message)
    : this._(success: false, message: message);

  final bool success;
  final String message;

  @override
  bool operator ==(Object other) {
    return other is AiConnectionTestResult &&
        other.success == success &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(success, message);
}

abstract interface class AiConnectionTester {
  Future<AiConnectionTestResult> testVolcAsr({
    required AiConfig config,
    required AiSecrets secrets,
  });

  Future<AiConnectionTestResult> testDeepSeek({
    required AiConfig config,
    required AiSecrets secrets,
  });
}
