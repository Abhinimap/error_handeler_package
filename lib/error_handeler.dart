import 'dart:io';

import 'package:error_handeler_flutter/internet_checker.dart';
import 'package:error_handeler_flutter/result.dart';
import 'package:error_handeler_flutter/snackbar.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// A class to provide error Handeling functionality
/// This uses Http as default Scheme and showSnackbar is default set to True
/// When APi call through get method of this class and internet is not available , A sncakbar will appear on the screen
/// Call init method of this class after Materialapp is Initialized and pass parameter to configure as per your choice
class ErrorHandelerFlutter {
  /// default set to True
  bool useHttp = true;

  /// default set to True
  bool showSnackbar = true;

  /// by default it will use http and show snackbar
  void init({bool? usehttp, bool? showSnackbar}) {
    useHttp = usehttp ?? true;
    showSnackbar = showSnackbar ?? true;
  }

  /// use ErrorHandelerFlutter().get() for API GET request.
  /// it will convert Response into Result
  /// use Success or Failure to get information about response
  /// ```
  ///   switch (resp) {
  ///        case Success(value: dynamic val):
  ///                 debugPrint(val);
  ///                  break;
  ///        case Failure(error: ErrorResponse res):
  ///                 debugPrint(res);
  /// ```
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

  /// use ErrorHandelerFlutter().post() for API GET request.
  /// it will convert Response into Result
  /// use Success or Failure to get information about response
  /// ```
  ///   switch (resp) {
  ///        case Success(value: dynamic val):
  ///                 debugPrint(val);
  ///                  break;
  ///        case Failure(error: ErrorResponse res):
  ///                 debugPrint(res);
  /// ```
  Future<Result> post(String url,
      {int timeout = 3,
      Map<String, String>? headers,
      required String body}) async {
    try {
      if (!await InternetConnectionChecker().hasConnection) {
        CustomSnackbar().showNoInternetSnackbar();
      }
      final response = await http
          .post(Uri.parse(url), headers: headers, body: body)
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
                  defaultMessage: 'Something Went wrong..')));
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
      print("error occurs  :$e");
      return Failure(ErrorResponse(
          errorHandelerFlutterEnum: ErrorHandelerFlutterEnum.undefined,
          errorResponseHolder: ErrorResponseHolder(
              defaultMessage: 'something went Wrong : $e')));
    }
  }

  /// get Failure class by providing statuscode and response
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

  /// returns errorResponseholder
  ErrorResponseHolder getErrorFromEnum(
      ErrorHandelerFlutterEnum errorEnum, String body) {
    return getEnumMap(responseBody: body)[errorEnum] ??
        ErrorResponseHolder(
            defaultMessage: 'Something Went Wrong..', responseBody: body);
  }

  /// return Map of Enum as key and ErrorResponseHolder as Value
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

/// A Class to Hold Error response in Structured manner
class ErrorResponseHolder {
  /// Message pre-defined in package
  String defaultMessage;

  /// Message provided by user in init method
  String? customMessage;

  /// contains response recieved from server
  String? responseBody;

  /// constructor
  ErrorResponseHolder(
      {required this.defaultMessage,
      this.responseBody,
      this.customMessage = ''});
}

/// Enum class for all the exceptions and statusCodes
enum ErrorHandelerFlutterEnum {
  /// 400
  badRequestError,

  /// TimeOut exception
  timeOutError,

  /// 403
  forbiddenError,

  /// 500
  internalServerError,

  /// 503
  serverUnavailableError,

  /// 401
  unAutherizationError,

  /// 404
  notFoundError,

  /// When Internet is not available
  noInternetError,

  /// Platform Exception
  platformExceptionError,

  /// SocketException  ( When base Url is no longer active or Internet issue)
  socketExceptionError,

  /// useually thrown when exception caught in Catch block or statusCode/Exception not defined in enum or Unkown to the package
  undefined,

  /// Format Exception
  formatExceptionError,
}
