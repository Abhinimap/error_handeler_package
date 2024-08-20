import 'package:error_handeler_flutter/error_handeler.dart';

/// Result class is a Super class of Success and Failure class
sealed class Result<R, E extends Exception> {
  const Result();
}

/// Inherit Result class and contains Successfull response of API Reuest
class Success<R, E extends Exception> extends Result<R, E> {
  /// contains a dynamic Success value
  final R value;

  ///constructor
  const Success(this.value);
}

/// Inherited from Result class
/// This class represent Failed response from the API request
class Failure<R, E extends Exception> extends Result<R, E> {
  /// Contains information about Failure of the APi request
  final ErrorResponse error;

  /// constructor
  const Failure(this.error);
}

/// contains details information about Failure of API Request
class ErrorResponse {
  /// Enum for Error
  ErrorHandelerFlutterEnum errorHandelerFlutterEnum;

  /// Error Response Holder
  ErrorResponseHolder errorResponseHolder;

  /// constructor
  ErrorResponse(
      {required this.errorHandelerFlutterEnum,
      required this.errorResponseHolder});
}
