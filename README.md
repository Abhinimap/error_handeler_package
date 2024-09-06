A Flutter Package to provide smooth Api call with All Error and Exception handeled.<br>
-  while using package's api request call you don't have to worry about any exception which might occured including PlatformException , FormatException , SocketException.<br>
- Instead of Exception throw this package focus on returning Exxception as Custom Failure class.<br>
- you can use Enum to find out which exception has occured and along with it you get access to default message for those Exception and response body of the api in your UI.<br>

This package also ensure proper network checking before making any APi request for making process fast and improve user experience.<br><br>

## Android Configuration 
On Android, for correct working in release mode, you must add INTERNET & ACCESS_NETWORK_STATE permissions to AndroidManifest.xml, follow the next lines:
    

```
    <manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Permissions for internet_connection_checker -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    
    <application
    
```

You can call `InternetConnectionChecker().hasConnection` to get bool Status of Internet Connection Availability, kindly note that this will only return Internet Status not Internet proivder device info like wifi, mobile,etc.



```
 if (!await InternetConnectionChecker().hasConnection) {
        CustomSnackbar().showNoInternetSnackbar();
      }     
```


 You can use this to show Alert Dialog or run some code 



 ## use of package for API Call

Initialize Snackbar after MaterialApp is configured.

 ```
  @override
  Widget build(BuildContext context) {
    
    // Make sure to call init function before using api call from ErrorHandelerFlutter class
    // context is needed to show No internet Snackbar,
    // Otherwise Snackbar will not appear when device is not connected to internet and api request is made
    CustomSnackbar().init(context);

    return Scaffold(
      appBar: AppBar(
```

Calling APi using ErrorHandelerFlutter class
use `ErrorHandelerFlutter().get(url)` to make GET request call
and get response as Result class, use Switch statement to iterate through Success or Failure

Below is sample code for how the request are made and how response are manipulated

```
 ElevatedButton(
                  onPressed: () async {
                    final Result response = await ErrorHandelerFlutter().get(url);
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
                        failure= resp;
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
                  child:const Text('Call Api'))
```