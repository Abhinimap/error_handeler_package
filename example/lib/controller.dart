import 'dart:convert';

import 'package:error_handeler_flutter/error_handeler_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ApiController extends GetxController {
  var responsebody = ''.obs;
  var defMesg = ''.obs;
  var customMesg = ''.obs;

  var errorEnum = ''.obs;
  var result = ''.obs;

  void clear() {
    defMesg.value = '';
    customMesg.value = '';
    errorEnum.value = '';
    result.value = '';
    responsebody.value = '';
  }

  Future<void> callApi() async {
    clear();
    final Result response = await ErrorHandlerFlutter.get(
      '/data/postdata',
    );
    // await ErrorHandlerFlutter.post('/data/postdata', body: '');
    debugPrint("response type  :${response.runtimeType}");
    switch (response) {
      case Success(value: dynamic data):
        debugPrint(
            'Use response as you like, or convert it into model: $data<--');

        result.value = ErrorHandlerFlutter.useHttp
            ? (await json.decode(data.body)).toString()
            : data.data.toString();
        debugPrint('result  :$data');
        break;
      case Failure(error: ErrorResponse resp):
        debugPrint('the error occured : ${resp.errorHandelerFlutterEnum.name}');

        defMesg.value = resp.errorResponseHolder.defaultMessage;
        customMesg.value = resp.errorResponseHolder.customMessage ?? '';
        errorEnum.value = resp.errorHandelerFlutterEnum.name;
        responsebody.value = resp.errorResponseHolder.responseBody ?? '';
        // pass through enums of failure to customize uses according to failures
        switch (resp.errorHandelerFlutterEnum) {
          case ErrorHandelerFlutterEnum.badRequestError:
            debugPrint(
                'the status is 400 , Bad request from client side :resbody:${resp.errorResponseHolder.responseBody}\n mesg :${resp.errorResponseHolder.defaultMessage} ');
            break;
          case ErrorHandelerFlutterEnum.notFoundError:
            debugPrint('404 , Api endpoint not found');
            break;
          default:
            debugPrint(
                'Not matched in main cases : ${resp.errorHandelerFlutterEnum.name} ${resp.errorResponseHolder.defaultMessage}');
        }
        break;
      default:
        debugPrint('Api Response not matched with any cases ');
    }
  }
}
