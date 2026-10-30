/// Sealed error model for app_core consumers.
sealed class AppFailure implements Exception {
  const AppFailure(this.message, {this.cause});

  final String message;
  final Object? cause;
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message, {super.cause});
}

final class StorageFailure extends AppFailure {
  const StorageFailure(super.message, {super.cause});
}

final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure(super.message, {super.cause});
}
