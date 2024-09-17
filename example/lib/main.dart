import 'package:error_handeler_flutter/dio_api.dart';
import 'package:error_handeler_flutter/error_handeler_flutter.dart';
import 'package:example/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  ErrorHandlerFlutter().init(usehttp: false);
  PackageDio.addInterceptors([]);

  PackageDio.setBaseOptions(
      baseUrl: 'https://66c45adfb026f3cc6ceefd10.mockapi.io');
  PackageDio.setUpDio();
  // PackageHttp.setup(host: '66c45adfb026f3cc6ceefd10.mockapi.io');
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
  // String url = 'https://mocki.io/v1/cbde42ba-5b27-4530-8fc5-2d3aa669ccbd';
  String url = 'https://66c45adfb026f3cc6ceefd10.mockapi.io/data/posstdata';

  final cont = Get.put(ApiController());
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
              if (cont.errorEnum.isNotEmpty)
                Obx(
                  () => Text(
                    cont.errorEnum.value,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              Obx(
                () => cont.defMesg.isNotEmpty
                    ? Text(
                        cont.defMesg.value,
                        style: Theme.of(context).textTheme.headlineMedium,
                      )
                    : SizedBox(),
              ),
              Obx(
                () => cont.customMesg.isNotEmpty
                    ? Text(
                        cont.customMesg.value,
                        style: Theme.of(context).textTheme.headlineMedium,
                      )
                    : SizedBox(),
              ),
              Obx(
                () => cont.responsebody.isNotEmpty
                    ? Text(
                        cont.responsebody.value,
                        style: Theme.of(context).textTheme.headlineMedium,
                      )
                    : SizedBox(),
              ),
              Obx(
                () => cont.result.isNotEmpty
                    ? Text(
                        cont.result.value,
                        style: Theme.of(context).textTheme.headlineMedium,
                      )
                    : SizedBox(),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                  onPressed: () async {
                    await cont.callApi();
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
