abstract class Failure {
  final String message;

  Failure({required this.message});
}

// Network-related failures
class ConnectionFailure extends Failure {
  ConnectionFailure({required String message}) : super(message: message);
}

class TimeoutFailure extends Failure {
  TimeoutFailure({required String message}) : super(message: message);
}

class RequestCancelledFailure extends Failure {
  RequestCancelledFailure() : super(message: 'Request was cancelled');
}

// Server-related failures
class ServerFailure extends Failure {
  ServerFailure({required String message}) : super(message: message);
}

class BadRequestFailure extends Failure {
  BadRequestFailure({required String message}) : super(message: message);
}

class UnauthorizedFailure extends Failure {
  UnauthorizedFailure({required String message}) : super(message: message);
}

class ForbiddenFailure extends Failure {
  ForbiddenFailure({required String message}) : super(message: message);
}

class NotFoundFailure extends Failure {
  NotFoundFailure({required String message}) : super(message: message);
}

class ConflictFailure extends Failure {
  ConflictFailure({required String message}) : super(message: message);
}

class TooManyRequestsFailure extends Failure {
  TooManyRequestsFailure({required String message}) : super(message: message);
}

// General failures
class UnknownFailure extends Failure {
  UnknownFailure({required String message}) : super(message: message);
}

class ValidationFailure extends Failure {
  ValidationFailure({required String message}) : super(message: message);
}
