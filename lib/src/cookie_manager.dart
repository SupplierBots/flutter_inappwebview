import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/src/cookie_handler.dart';

///Class that implements a singleton object (shared instance) which the global [CookieHandler] used by all WebView instances.
///On Android, it is implemented using [CookieManager](https://developer.android.com/reference/android/webkit/CookieManager).
///On iOS, it is implemented using [WKHTTPCookieStore](https://developer.apple.com/documentation/webkit/wkhttpcookiestore).
///
///**NOTE for iOS below 11.0 (LIMITED SUPPORT!)**: in this case, almost all of the methods ([CookieManager.deleteAllCookies] and [IOSCookieManager.getAllCookies] are not supported!)
///has been implemented using JavaScript because there is no other way to work with them on iOS below 11.0.
///See https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies for JavaScript restrictions.
class CookieManager {
  static CookieHandler? _instance;
  static const MethodChannel _channel = const MethodChannel(
      'com.pichillilorenzo/flutter_inappwebview_cookiemanager');

  ///Contains only iOS-specific methods of [CookieHandler].
  late IOSCookieHandler ios;

  ///Gets the [CookieHandler] shared instance.
  static CookieHandler instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static CookieHandler _init() {
    _channel.setMethodCallHandler(_handleMethod);
    _instance = CookieHandler(channel: _channel);
    _instance!.ios = IOSCookieManager.instance();
    return _instance!;
  }

  static Future<dynamic> _handleMethod(MethodCall call) async {}
}

///Class that contains only iOS-specific methods of [CookieManager].
class IOSCookieManager {
  static IOSCookieHandler? _instance;

  ///Gets the [IOSCookieHandler] shared instance.
  static IOSCookieHandler instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static IOSCookieHandler _init() {
    _instance = IOSCookieHandler(
      channel: MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_cookiemanager',
      ),
    );
    return _instance!;
  }
}
