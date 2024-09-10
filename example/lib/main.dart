import 'dart:convert';

import 'package:error_handeler_flutter/error_handeler_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Error Handeler Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isConnected = false;
  Map? _result;
  ErrorResponse? failure;

  // enter your own url to test
  String url = 'https://mocki.io/v1/cbde42ba-5b27-4530-8fc5-2d3aa669ccbd';

  @override
  Widget build(BuildContext context) {
    // Make sure to call init function before using api call from ErrorHandelerFlutter class
    // context is needed to show No internet Snackbar
    CustomSnackbar().init(context);

    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Internet Connection: ${isConnected ? 'Connected' : 'Not Connected'}',
              ),
              Text(
                '$_result',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                  onPressed: () async {
                    final Result response =
                        await ErrorHandelerFlutter().post(url, body: '');
                    switch (response) {
                      case Success(value: dynamic result):
                        debugPrint(
                            'Use response as you like, or convert it into model: $result');
                        setState(() {
                          _result = json.decode(result) as Map;
                        });
                        break;
                      case Failure(error: ErrorResponse resp):
                        setState(() {
                          failure = resp;
                        });
                        debugPrint(
                            'the error occured : ${resp.errorHandelerFlutterEnum.name}');
                        // pass through enums of failure to customize uses according to failures
                        switch (resp.errorHandelerFlutterEnum) {
                          case ErrorHandelerFlutterEnum.badRequestError:
                            debugPrint(
                                'the status is 400 , Bad request from client side ');
                            break;
                          case ErrorHandelerFlutterEnum.notFoundError:
                            debugPrint('404 , Api endpoint not found');
                            break;
                          default:
                            debugPrint(
                                'Not matched in cases : ${resp.errorHandelerFlutterEnum.name}');
                        }
                        break;
                      default:
                        debugPrint('Api Response not matched with any cases ');
                    }
                  },
                  child: const Text('Call Api'))
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final connected = await InternetConnectionChecker().hasConnection;
          setState(() {
            isConnected = connected;
          });
        },
        tooltip: 'Internet Connection',
        child: const Icon(Icons.wifi),
      ),
    );
  }
}
