/// Sealed error model for app_core consumers.
sealed class AppFailure implements Exception {
  const new(this.message, {this.cause});

  final String message;
  final Object? cause;
}

final class NetworkFailure extends AppFailure {
  const new(super.message, {super.cause});
}

final class StorageFailure extends AppFailure {
  const new(super.message, {super.cause});
}

final class UnexpectedFailure extends AppFailure {
  const new(super.message, {super.cause});
}
