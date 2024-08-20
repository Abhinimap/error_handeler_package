A Flutter Package to provide smooth Api call with All Error and Exception handeled.<br>
-  while using package's api request call you don't have to worry about any exception which might occured including PlatformException , FormatException , SocketException.<br>
- Instead of Exception throw this package focus on returning Exxception as Custom Failure class.<br>
- you can use Enum to find out which exception has occured and along with it you get access to default message for those Exception and response body of the api in your UI.<br>

This package also ensure proper network checking before making any APi request for making process fast and improve user experience.<br><br>

You can call `InternetConnectionChecker().hasConnection` to get bool Status of Internet Connection Availability, kindly note that this will only return Internet Status not Internet proivder device info like wifi, mobile,etc. <br>

```
 if (!await InternetConnectionChecker().hasConnection) {
        CustomSnackbar().showNoInternetSnackbar();
      }
```
 <br>You can use this to show Alert Dialog or run some code 
