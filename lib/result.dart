
import 'package:error_handeler_flutter/error_handeler.dart';

sealed class Result<R,E extends Exception>  {
const Result();
}

class Success<R,E extends Exception> extends Result<R,E >{
  final R value;
  const Success(this.value);
}

class Failure<R,E extends Exception> extends Result<R,E >{
  final ErrorResponse error;
  const Failure(this.error);
}

 class ErrorResponse{
  ErrorHandelerFlutterEnum errorHandelerFlutterEnum;
  ErrorResponseHolder errorResponseHolder;

  ErrorResponse({required this.errorHandelerFlutterEnum,required this.errorResponseHolder});
}