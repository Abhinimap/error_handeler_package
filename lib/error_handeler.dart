
import 'dart:io';

import 'package:error_handeler_flutter/internet_checker.dart';
import 'package:error_handeler_flutter/result.dart';
import 'package:error_handeler_flutter/snackbar.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ErrorHandelerFlutter {
  bool useHttp = true;
  bool showSnackbar = true;

  /// by default it will use http and show snackbar
  void init({bool? usehttp, bool? showSnackbar}) {
    useHttp = usehttp ?? true;
    showSnackbar = showSnackbar ?? true;
  }

  Future<Result> get(String url,
      {int timeout = 3, Map<String, String>? headers}) async {
    try {
      if (!await InternetConnectionChecker().hasConnection) {
        CustomSnackbar().showNoInternetSnackbar();
      }
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(Duration(seconds: timeout));

      switch (response.statusCode) {
        case >= 200 && < 300:
          return Success(response.body);
        case >= 400:
          return Failure(findErrorFromStatusCode(
              code: response.statusCode, response: response));
        default:
          return Failure(ErrorResponse(
              errorHandelerFlutterEnum: ErrorHandelerFlutterEnum.undefined,
              errorResponseHolder: ErrorResponseHolder(
                  defaultMessage: 'Something Went Wrnog..')));
      }
    } on PlatformException {
      return Failure(ErrorResponse(
          errorHandelerFlutterEnum:
              ErrorHandelerFlutterEnum.platformExceptionError,
          errorResponseHolder: ErrorResponseHolder(
              defaultMessage: 'Platform Exception Caught')));
    } on SocketException catch (e) {
      return Failure(ErrorResponse(
          errorHandelerFlutterEnum:
              ErrorHandelerFlutterEnum.socketExceptionError,
          errorResponseHolder:
              ErrorResponseHolder(defaultMessage: 'Socket Exception:$e')));
    } on FormatException {
      return Failure(ErrorResponse(
          errorHandelerFlutterEnum:
              ErrorHandelerFlutterEnum.formatExceptionError,
          errorResponseHolder:
              ErrorResponseHolder(defaultMessage: 'format exception Error')));
    } catch (e) {
      return Failure(ErrorResponse(
          errorHandelerFlutterEnum: ErrorHandelerFlutterEnum.undefined,
          errorResponseHolder: ErrorResponseHolder(
              defaultMessage: 'something went Wrong : $e')));
    }
  }

  findErrorFromStatusCode(
      {required int code, required http.Response response}) {
    switch (code) {
      case >= 200 && < 300:
        break;
      case 400:
        return Failure(ErrorResponse(
            errorHandelerFlutterEnum: ErrorHandelerFlutterEnum.badRequestError,
            errorResponseHolder: getErrorFromEnum(
                ErrorHandelerFlutterEnum.badRequestError, response.body)));
      default:
        return Failure(ErrorResponse(
            errorHandelerFlutterEnum: ErrorHandelerFlutterEnum.undefined,
            errorResponseHolder: ErrorResponseHolder(
                defaultMessage: 'Something went wrong....',
                responseBody: response.body)));
    }
  }

  ErrorResponseHolder getErrorFromEnum(
      ErrorHandelerFlutterEnum errorEnum, String body) {
    return getEnumMap(responseBody: body)[errorEnum] ??
        ErrorResponseHolder(
            defaultMessage: 'Something Went Wrong..', responseBody: body);
  }

  Map<ErrorHandelerFlutterEnum, ErrorResponseHolder> getEnumMap({
    String? customMessage,
    required String responseBody,
  }) =>
      {
        ErrorHandelerFlutterEnum.badRequestError: (ErrorResponseHolder(
            defaultMessage: 'Bad Request kindly check your request body',
            responseBody: responseBody)),
        ErrorHandelerFlutterEnum.unAutherizationError: (ErrorResponseHolder(
            defaultMessage: 'You are not authrized to make request',
            responseBody: responseBody)),
        ErrorHandelerFlutterEnum.forbiddenError: (ErrorResponseHolder(
            defaultMessage: 'You are forbid to make request',
            responseBody: responseBody)),
        ErrorHandelerFlutterEnum.timeOutError: (ErrorResponseHolder(
            defaultMessage: 'Unable to fetch reponse within given time',
            responseBody: responseBody)),
        ErrorHandelerFlutterEnum.serverUnavailableError: (ErrorResponseHolder(
          defaultMessage: 'Server is not Available at this Time',
        )),
        ErrorHandelerFlutterEnum.internalServerError: (ErrorResponseHolder(
            defaultMessage:
                'Internal Server Error,unable to make request to the server')),
        ErrorHandelerFlutterEnum.notFoundError: (ErrorResponseHolder(
            defaultMessage: 'Unable to reach to the Server, Server Not Found',
            responseBody: responseBody)),
        ErrorHandelerFlutterEnum.undefined: (ErrorResponseHolder(
            defaultMessage: 'Something went wrong...',
            responseBody: responseBody)),
      };
}

class ErrorResponseHolder {
  String defaultMessage;
  String? customMessage;
  String? responseBody;

  ErrorResponseHolder(
      {required this.defaultMessage,
      this.responseBody,
      this.customMessage = ''});
}

enum ErrorHandelerFlutterEnum {
  badRequestError,
  timeOutError,
  forbiddenError,
  internalServerError,
  serverUnavailableError,
  unAutherizationError,
  notFoundError,
  noInternetError,
  platformExceptionError,
  socketExceptionError,
  undefined,
  formatExceptionError,
}
