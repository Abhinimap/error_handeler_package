import 'package:error_handeler_flutter/dio_api.dart';
import 'package:error_handeler_flutter/http_api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'error_handeler_flutter.dart';

/// A class to provide error Handeling functionality
/// This uses Http as default Scheme and showSnackbar is default set to True
/// When APi call through get method of this class and internet is not available , A sncakbar will appear on the screen
/// Call init method of this class after Materialapp is Initialized and pass parameter to configure as per your choice
class ErrorHandlerFlutter {
  /// default set to True
  static bool useHttp = true;

  /// default set to True
  static bool showSnackbar = true;

  /// by default it will use http and show snackbar
  void init({bool? usehttp, bool? showSnackbar}) {
    useHttp = usehttp ?? true;
    showSnackbar = showSnackbar ?? true;
  }

  /// map response into Result
  static Result mapHttpResponseToResult(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Success(response);
    } else {
      switch (response.statusCode) {
        case >= 200 && < 400:
          return Success(response.body);

        case >= 400 && < 500:
          return _failure400_499(response.statusCode, response);
        case >= 500:
          return _failure500_infinity(response.statusCode, response);

        default:
          return Failure(ErrorResponse(
              errorHandelerFlutterEnum: ErrorHandelerFlutterEnum.undefined, errorResponseHolder: ErrorResponseHolder(defaultMessage: 'Something went wrong', responseBody: response.body)));
      }
    }
  }

  /// map Dio response into Result
  static Result mapDioResponseToResult(response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Success(response);
    } else {
      switch (response.statusCode) {
        case >= 200 && < 400:
          return Success(response.data);

        case >= 400 && < 500:
          return _failure400_499(response.statusCode, response);
        case >= 500:
          return _failure500_infinity(response.statusCode, response);

        default:
          return Failure(ErrorResponse(
              errorHandelerFlutterEnum: ErrorHandelerFlutterEnum.undefined, errorResponseHolder: ErrorResponseHolder(defaultMessage: 'Something went wrong', responseBody: response.body)));
      }
    }
  }

  static Failure _failure400_499(int s, res) {
    switch (s) {
      case 400:
        return Failure(
          ErrorResponse(
              errorHandelerFlutterEnum: ErrorHandelerFlutterEnum.badRequestError,
              errorResponseHolder: ErrorResponseHolder(defaultMessage: 'Bad Request..', responseBody: res.body, customMessage: 'Bad Request.. ${res is http.Response ? res.body : res.data}')),
        );
      case 401:
        return Failure(
          ErrorResponse(
              errorHandelerFlutterEnum: ErrorHandelerFlutterEnum.unAuthorizationError,
              errorResponseHolder: ErrorResponseHolder(
                  defaultMessage: 'You are not authorized to access this resources..', responseBody: res.body, customMessage: 'Unauthorized... ${res is http.Response ? res.body : res.data}')),
        );
      case 403:
        return Failure(
          ErrorResponse(
              errorHandelerFlutterEnum: ErrorHandelerFlutterEnum.forbiddenError,
              errorResponseHolder: ErrorResponseHolder(
                  defaultMessage: 'You are restricted to access this resources..', responseBody: res.body, customMessage: 'Forbidden... ${res is http.Response ? res.body : res.data}')),
        );
      case 404:
        return Failure(
          ErrorResponse(
              errorHandelerFlutterEnum: ErrorHandelerFlutterEnum.notFoundError,
              errorResponseHolder: ErrorResponseHolder(
                  defaultMessage: 'Resource want not find at ${res.request?.url}..', responseBody: res.body, customMessage: '404 Not Found... ${res is http.Response ? res.body : res.data}')),
        );
      case 409:
        return Failure(
          ErrorResponse(
              errorHandelerFlutterEnum: ErrorHandelerFlutterEnum.conflictError,
              errorResponseHolder: ErrorResponseHolder(defaultMessage: 'data Conflicted', responseBody: res.body, customMessage: '409... ${res is http.Response ? res.body : res.data}')),
        );
      default:
        return Failure(ErrorResponse(
            errorResponseHolder: ErrorResponseHolder(
              defaultMessage: 'Something went wrong',
              customMessage: 'Error : ${res.body}',
              responseBody: res.body,
            ),
            errorHandelerFlutterEnum: ErrorHandelerFlutterEnum.undefined));
    }
  }

  static Failure _failure500_infinity(int s, res) {
    switch (s) {
      case 500:
        return Failure(
          ErrorResponse(
              errorHandelerFlutterEnum: ErrorHandelerFlutterEnum.internalServerError,
              errorResponseHolder:
                  ErrorResponseHolder(defaultMessage: 'Internal Server Error..', responseBody: res.body, customMessage: 'Internal Server Error.. ${res is http.Response ? res.body : res.data}')),
        );
      case 501:
        return Failure(
          ErrorResponse(
              errorHandelerFlutterEnum: ErrorHandelerFlutterEnum.serverNotSupportError,
              errorResponseHolder: ErrorResponseHolder(
                  defaultMessage: 'Server does not support this functionality', responseBody: res.body, customMessage: 'server not supported... ${res is http.Response ? res.body : res.data}')),
        );
      case 503:
        return Failure(
          ErrorResponse(
              errorHandelerFlutterEnum: ErrorHandelerFlutterEnum.serverUnavailableError,
              errorResponseHolder:
                  ErrorResponseHolder(responseBody: res.body, defaultMessage: 'Server Not Available..', customMessage: 'Server Not available... ${res is http.Response ? res.body : res.data}')),
        );
      case 504:
        return Failure(
          ErrorResponse(
              errorHandelerFlutterEnum: ErrorHandelerFlutterEnum.serverGatewayTimeOut,
              errorResponseHolder: ErrorResponseHolder(
                  defaultMessage: 'server time out on ${res.request?.url}..', responseBody: res.body, customMessage: 'server request time out.. ${res is http.Response ? res.body : res.data}')),
        );

      default:
        return Failure(ErrorResponse(
            errorResponseHolder: ErrorResponseHolder(
              defaultMessage: 'Something went wrong',
              customMessage: 'Error on ${res.request?.url}',
              responseBody: res.body,
            ),
            errorHandelerFlutterEnum: ErrorHandelerFlutterEnum.undefined));
    }
  }

  /// get request
  static Future<Result> get(String endpoint, {int timeout = 3, Map<String, dynamic>? queryPara, Map<String, String>? headers}) async {
    if (!await InternetConnectionChecker().hasConnection) {
      CustomSnackbar().showNoInternetSnackbar();
    }
    if (useHttp) {
      final res = await PackageHttp.getRequest(
        url: PackageHttp.getUriFromEndpoints(endpoint: endpoint, queryParams: queryPara),
        headers: headers,
      );

      if (res.runtimeType == Failure) {
        return res as Failure;
      }
      debugPrint("api call was on  : ${(res as http.Response).request?.url}");
      return mapHttpResponseToResult(res);
    } else {
      final res = await PackageDio.dioGet(urlPath: endpoint, headers: headers, queryPara: queryPara);

      if (res.runtimeType == Failure) {
        return res as Failure;
      }
      return mapDioResponseToResult(res);
    }
  }

  /// POST request
  static Future<Result> post(String endpoint, {int timeout = 3, Map<String, dynamic>? queryPara, dynamic body, Map<String, String>? headers}) async {
    if (!await InternetConnectionChecker().hasConnection) {
      CustomSnackbar().showNoInternetSnackbar();
    }
    if (useHttp) {
      final res = await PackageHttp.postRequest(
        url: PackageHttp.getUriFromEndpoints(endpoint: endpoint, queryParams: queryPara),
        headers: headers,
        body: body,
      );

      if (res.runtimeType == Failure) {
        return res as Failure;
      }
      return mapHttpResponseToResult(res);
    } else {
      final res = await PackageDio.dioPost(urlPath: endpoint, headers: headers, queryPara: queryPara);
      debugPrint("response in post request :$res");
      if (res.runtimeType == Failure) {
        return res as Failure;
      }
      return mapDioResponseToResult(res);
    }
  }

  /// Delete request
  static Future<Result> delete(String endpoint, {int timeout = 3, Map<String, dynamic>? queryPara, dynamic body, Map<String, String>? headers}) async {
    if (!await InternetConnectionChecker().hasConnection) {
      CustomSnackbar().showNoInternetSnackbar();
    }
    if (useHttp) {
      final res = await PackageHttp.deleteRequest(
        url: PackageHttp.getUriFromEndpoints(endpoint: endpoint, queryParams: queryPara),
        headers: headers,
      );

      if (res.runtimeType == Failure) {
        return res as Failure;
      }
      return mapHttpResponseToResult(res);
    } else {
      final res = await PackageDio.dioDelete(urlPath: endpoint, headers: headers, queryPara: queryPara);
      debugPrint("response in post request :$res");
      if (res.runtimeType == Failure) {
        return res as Failure;
      }
      return mapDioResponseToResult(res);
    }
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
  // Future<Result> get(String url,
  //     {int timeout = 3, Map<String, String>? headers}) async {
  //   try {
  //     if (!await InternetConnectionChecker().hasConnection) {
  //       CustomSnackbar().showNoInternetSnackbar();
  //     }
  //     print("fetching data from : $url");
  //     final response = await http
  //         .get(Uri.parse(url), headers: headers)
  //         .timeout(Duration(seconds: timeout));
  //
  //     switch (response.statusCode) {
  //       case >= 200 && < 300:
  //         return Success(response.body);
  //       case >= 400:
  //         return findErrorFromStatusCode(
  //             code: response.statusCode, response: response);
  //       default:
  //         return Failure(ErrorResponse(
  //             errorHandelerFlutterEnum: ErrorHandelerFlutterEnum.undefined,
  //             errorResponseHolder: ErrorResponseHolder(
  //                 defaultMessage: 'Something Went Wrnog..')));
  //     }
  //   } on PlatformException {
  //     return Failure(ErrorResponse(
  //         errorHandelerFlutterEnum:
  //             ErrorHandelerFlutterEnum.platformExceptionError,
  //         errorResponseHolder: ErrorResponseHolder(
  //             defaultMessage: 'Platform Exception Caught')));
  //   } on SocketException catch (e) {
  //     return Failure(ErrorResponse(
  //         errorHandelerFlutterEnum:
  //             ErrorHandelerFlutterEnum.socketExceptionError,
  //         errorResponseHolder:
  //             ErrorResponseHolder(defaultMessage: 'Socket Exception:$e')));
  //   } on FormatException {
  //     return Failure(ErrorResponse(
  //         errorHandelerFlutterEnum:
  //             ErrorHandelerFlutterEnum.formatExceptionError,
  //         errorResponseHolder:
  //             ErrorResponseHolder(defaultMessage: 'format exception Error')));
  //   } catch (e) {
  //     return Failure(ErrorResponse(
  //         errorHandelerFlutterEnum: ErrorHandelerFlutterEnum.undefined,
  //         errorResponseHolder: ErrorResponseHolder(
  //             defaultMessage: 'something went Wrong : $e')));
  //   }
  // }

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
  // Future<Result<dynamic>> post(String url,
  //     {int timeout = 3,
  //     Map<String, String>? headers,
  //     required String body}) async {
  //   try {
  //     if (!await InternetConnectionChecker().hasConnection) {
  //       CustomSnackbar().showNoInternetSnackbar();
  //     }
  //     debugPrint("fetching data from url :$url");
  //     final response = await http
  //         .post(Uri.parse(url), headers: headers, body: body)
  //         .timeout(Duration(seconds: timeout));
  //     debugPrint("response : ${response.body},statud :${response.statusCode}");
  //     switch (response.statusCode) {
  //       case >= 200 && < 300:
  //         return Success(response.body);
  //       case >= 400:
  //         return findErrorFromStatusCode(
  //             code: response.statusCode, response: response);
  //       default:
  //         return Failure(ErrorResponse(
  //             errorHandelerFlutterEnum: ErrorHandelerFlutterEnum.undefined,
  //             errorResponseHolder: ErrorResponseHolder(
  //                 defaultMessage: 'Something Went wrong..')));
  //     }
  //   } on PlatformException {
  //     return Failure(ErrorResponse(
  //         errorHandelerFlutterEnum:
  //             ErrorHandelerFlutterEnum.platformExceptionError,
  //         errorResponseHolder: ErrorResponseHolder(
  //             defaultMessage: 'Platform Exception Caught')));
  //   } on SocketException catch (e) {
  //     return Failure(ErrorResponse(
  //         errorHandelerFlutterEnum:
  //             ErrorHandelerFlutterEnum.socketExceptionError,
  //         errorResponseHolder:
  //             ErrorResponseHolder(defaultMessage: 'Socket Exception:$e')));
  //   } on FormatException {
  //     return Failure(ErrorResponse(
  //         errorHandelerFlutterEnum:
  //             ErrorHandelerFlutterEnum.formatExceptionError,
  //         errorResponseHolder:
  //             ErrorResponseHolder(defaultMessage: 'format exception Error')));
  //   } catch (e) {
  //     debugPrint("error occurs  :$e");
  //     return Failure(ErrorResponse(
  //         errorHandelerFlutterEnum: ErrorHandelerFlutterEnum.undefined,
  //         errorResponseHolder: ErrorResponseHolder(
  //             defaultMessage: 'something went Wrong : $e')));
  //   }
//   // }
//   /// returns errorResponse holder
//   ErrorResponseHolder getErrorFromEnum(
//       ErrorHandelerFlutterEnum errorEnum, String body) {
//     return getEnumMap(responseBody: body)[errorEnum] ??
//         ErrorResponseHolder(
//             defaultMessage: 'Something Went Wrong..', responseBody: body);
//   }
//
//   /// return Map of Enum as key and ErrorResponseHolder as Value
//   Map<ErrorHandelerFlutterEnum, ErrorResponseHolder> getEnumMap({
//     String? customMessage,
//     required String responseBody,
//   }) =>
//       {
//         ErrorHandelerFlutterEnum.badRequestError: (ErrorResponseHolder(
//             defaultMessage: 'Bad Request kindly check your request body',
//             responseBody: responseBody)),
//         ErrorHandelerFlutterEnum.unAuthorizationError: (ErrorResponseHolder(
//             defaultMessage: 'You are not authrized to make request',
//             responseBody: responseBody)),
//         ErrorHandelerFlutterEnum.forbiddenError: (ErrorResponseHolder(
//             defaultMessage: 'You are forbid to make request',
//             responseBody: responseBody)),
//         ErrorHandelerFlutterEnum.timeOutError: (ErrorResponseHolder(
//             defaultMessage: 'Unable to fetch reponse within given time',
//             responseBody: responseBody)),
//         ErrorHandelerFlutterEnum.serverUnavailableError: (ErrorResponseHolder(
//           defaultMessage: 'Server is not Available at this Time',
//         )),
//         ErrorHandelerFlutterEnum.internalServerError: (ErrorResponseHolder(
//             defaultMessage:
//                 'Internal Server Error,unable to make request to the server')),
//         ErrorHandelerFlutterEnum.notFoundError: (ErrorResponseHolder(
//             defaultMessage: 'Unable to reach to the Server, Server Not Found',
//             responseBody: responseBody)),
//         ErrorHandelerFlutterEnum.undefined: (ErrorResponseHolder(
//             defaultMessage: 'Something went wrong...',
//             responseBody: responseBody)),
//       };
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
  ErrorResponseHolder({required this.defaultMessage, this.responseBody, this.customMessage = ''});
}

/// Enum class for all the exceptions and statusCodes
enum ErrorHandelerFlutterEnum {
  /// 400
  badRequestError,

  /// TimeOut exception
  timeOutError,

  /// 403
  forbiddenError,

  /// 409
  conflictError,

  /// 500
  internalServerError,

  /// 501
  serverNotSupportError,

  /// 503
  serverUnavailableError,

  /// server Gateway TimeOut
  /// The server, acting as a gateway or proxy, did not receive a timely response from an upstream server
  serverGatewayTimeOut,

  /// 401
  unAuthorizationError,

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
