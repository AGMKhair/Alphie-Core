abstract class Failure {
  final String message;
  final int? code;

  const Failure(this.message, [this.code]);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.code]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection', super.code]);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, [super.code]);
}

class ValidationFailure extends Failure {
  final Map<String, dynamic>? errors;
  const ValidationFailure(super.message, [this.errors, super.code]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache failure', super.code]);
}
