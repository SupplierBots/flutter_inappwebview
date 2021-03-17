import 'dart:async';
import 'dart:core';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import '../_static_channel.dart';

import '../../types.dart';

///Class represents the iOS controller that contains only iOS-specific methods for the WebView.
class IOSInAppWebViewController {
  late MethodChannel _channel;
  static MethodChannel _staticChannel = IN_APP_WEBVIEW_STATIC_CHANNEL;

  IOSInAppWebViewController({required MethodChannel channel}) {
    this._channel = channel;
  }

  ///Reloads the current page, performing end-to-end revalidation using cache-validating conditionals if possible.
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wkwebview/1414956-reloadfromorigin
  Future<void> reloadFromOrigin() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('reloadFromOrigin', args);
  }

  ///Generates PDF data from the web view’s contents asynchronously.
  ///Returns `null` if a problem occurred.
  ///
  ///[iosWKPdfConfiguration] represents the object that specifies the portion of the web view to capture as PDF data.
  ///
  ///**NOTE**: available only on iOS 14.0+.
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wkwebview/3650490-createpdf
  Future<Uint8List?> createPdf(
      {IOSWKPDFConfiguration? iosWKPdfConfiguration}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent(
        'iosWKPdfConfiguration', () => iosWKPdfConfiguration?.toMap());
    return await _channel.invokeMethod('createPdf', args);
  }

  ///Creates a web archive of the web view’s current contents asynchronously.
  ///Returns `null` if a problem occurred.
  ///
  ///**NOTE**: available only on iOS 14.0+.
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wkwebview/3650491-createwebarchivedata
  Future<Uint8List?> createWebArchiveData() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('createWebArchiveData', args);
  }

  ///A Boolean value indicating whether all resources on the page have been loaded over securely encrypted connections.
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wkwebview/1415002-hasonlysecurecontent
  Future<bool> hasOnlySecureContent() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('hasOnlySecureContent', args);
  }

  ///Returns a Boolean value that indicates whether WebKit natively supports resources with the specified URL scheme.
  ///
  ///[urlScheme] represents the URL scheme associated with the resource.
  ///
  ///**NOTE**: available only on iOS 11.0+.
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wkwebview/2875370-handlesurlscheme
  static Future<bool> handlesURLScheme(String urlScheme) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('urlScheme', () => urlScheme);
    return await _staticChannel.invokeMethod('handlesURLScheme', args);
  }

  //! COOKIES PATCH

  ///Sets a cookie for the given [url]. Any existing cookie with the same [host], [path] and [name] will be replaced with the new cookie.
  ///The cookie being set will be ignored if it is expired.
  ///
  ///The default value of [path] is `"/"`.
  ///If [domain] is `null`, its default value will be the domain name of [url].
  ///
  ///[iosBelow11WebViewController] could be used if you need to set a session-only cookie using JavaScript (so [isHttpOnly] cannot be set, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies)
  ///on the current URL of the [WebView] managed by that controller when you need to target iOS below 11. In this case the [url] parameter is ignored.
  ///
  ///**NOTE for iOS below 11.0**: If [iosBelow11WebViewController] is `null` or JavaScript is disabled for it, it will try to use a [HeadlessInAppWebView]
  ///to set the cookie (session-only cookie won't work! In that case, you should set also [expiresDate] or [maxAge]).
  Future<void> setCookie({
    required Uri url,
    required String name,
    required String value,
    String? domain,
    String path = "/",
    int? expiresDate,
    int? maxAge,
    bool? isSecure,
    bool? isHttpOnly,
    HTTPCookieSameSitePolicy? sameSite,
  }) async {
    if (domain == null) domain = _getDomainName(url);

    assert(url.toString().isNotEmpty);
    assert(name.isNotEmpty);
    assert(value.isNotEmpty);
    assert(domain.isNotEmpty);
    assert(path.isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url.toString());
    args.putIfAbsent('name', () => name);
    args.putIfAbsent('value', () => value);
    args.putIfAbsent('domain', () => domain);
    args.putIfAbsent('path', () => path);
    args.putIfAbsent('expiresDate', () => expiresDate?.toString());
    args.putIfAbsent('maxAge', () => maxAge);
    args.putIfAbsent('isSecure', () => isSecure);
    args.putIfAbsent('isHttpOnly', () => isHttpOnly);
    args.putIfAbsent('sameSite', () => sameSite?.toValue());

    await _channel.invokeMethod('setCookie', args);
  }

  ///Gets all the cookies for the given [url].
  ///
  ///[iosBelow11WebViewController] is used for getting the cookies (also session-only cookies) using JavaScript (cookies with `isHttpOnly` enabled cannot be found, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies)
  ///from the current context of the [WebView] managed by that controller when you need to target iOS below 11. JavaScript must be enabled in order to work.
  ///In this case the [url] parameter is ignored.
  ///
  ///**NOTE for iOS below 11.0**: All the cookies returned this way will have all the properties to `null` except for [Cookie.name] and [Cookie.value].
  ///If [iosBelow11WebViewController] is `null` or JavaScript is disabled for it, it will try to use a [HeadlessInAppWebView]
  ///to get the cookies (session-only cookies and cookies with `isHttpOnly` enabled won't be found!).
  Future<List<Cookie>> getCookies({
    required Uri url,
  }) async {
    assert(url.toString().isNotEmpty);

    List<Cookie> cookies = [];

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url.toString());
    List<dynamic> cookieListMap =
        await _channel.invokeMethod('getCookies', args);
    cookieListMap = cookieListMap.cast<Map<dynamic, dynamic>>();

    cookieListMap.forEach((cookieMap) {
      cookies.add(Cookie(
          name: cookieMap["name"],
          value: cookieMap["value"],
          expiresDate: cookieMap["expiresDate"],
          isSessionOnly: cookieMap["isSessionOnly"],
          domain: cookieMap["domain"],
          sameSite: HTTPCookieSameSitePolicy.fromValue(cookieMap["sameSite"]),
          isSecure: cookieMap["isSecure"],
          isHttpOnly: cookieMap["isHttpOnly"],
          path: cookieMap["path"]));
    });
    return cookies;
  }

  ///Gets a cookie by its [name] for the given [url].
  ///
  ///[iosBelow11WebViewController] is used for getting the cookie (also session-only cookie) using JavaScript (cookie with `isHttpOnly` enabled cannot be found, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies)
  ///from the current context of the [WebView] managed by that controller when you need to target iOS below 11. JavaScript must be enabled in order to work.
  ///In this case the [url] parameter is ignored.
  ///
  ///**NOTE for iOS below 11.0**: All the cookies returned this way will have all the properties to `null` except for [Cookie.name] and [Cookie.value].
  ///If [iosBelow11WebViewController] is `null` or JavaScript is disabled for it, it will try to use a [HeadlessInAppWebView]
  ///to get the cookie (session-only cookie and cookie with `isHttpOnly` enabled won't be found!).
  Future<Cookie?> getCookie({
    required Uri url,
    required String name,
  }) async {
    assert(url.toString().isNotEmpty);
    assert(name.isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url.toString());
    List<dynamic> cookies = await _channel.invokeMethod('getCookies', args);
    cookies = cookies.cast<Map<dynamic, dynamic>>();
    for (var i = 0; i < cookies.length; i++) {
      cookies[i] = cookies[i].cast<String, dynamic>();
      if (cookies[i]["name"] == name)
        return Cookie(
            name: cookies[i]["name"],
            value: cookies[i]["value"],
            expiresDate: cookies[i]["expiresDate"],
            isSessionOnly: cookies[i]["isSessionOnly"],
            domain: cookies[i]["domain"],
            sameSite:
                HTTPCookieSameSitePolicy.fromValue(cookies[i]["sameSite"]),
            isSecure: cookies[i]["isSecure"],
            isHttpOnly: cookies[i]["isHttpOnly"],
            path: cookies[i]["path"]);
    }
    return null;
  }

  ///Removes a cookie by its [name] for the given [url], [domain] and [path].
  ///
  ///The default value of [path] is `"/"`.
  ///If [domain] is empty, its default value will be the domain name of [url].
  ///
  ///[iosBelow11WebViewController] is used for deleting the cookie (also session-only cookie) using JavaScript (cookie with `isHttpOnly` enabled cannot be deleted, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies)
  ///from the current context of the [WebView] managed by that controller when you need to target iOS below 11. JavaScript must be enabled in order to work.
  ///In this case the [url] parameter is ignored.
  ///
  ///**NOTE for iOS below 11.0**: If [iosBelow11WebViewController] is `null` or JavaScript is disabled for it, it will try to use a [HeadlessInAppWebView]
  ///to delete the cookie (session-only cookie and cookie with `isHttpOnly` enabled won't be deleted!).
  Future<void> deleteCookie({
    required Uri url,
    required String name,
    String domain = "",
    String path = "/",
  }) async {
    if (domain.isEmpty) domain = _getDomainName(url);

    assert(url.toString().isNotEmpty);
    assert(name.isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url.toString());
    args.putIfAbsent('name', () => name);
    args.putIfAbsent('domain', () => domain);
    args.putIfAbsent('path', () => path);
    await _channel.invokeMethod('deleteCookie', args);
  }

  ///Removes all cookies for the given [url], [domain] and [path].
  ///
  ///The default value of [path] is `"/"`.
  ///If [domain] is empty, its default value will be the domain name of [url].
  ///
  ///[iosBelow11WebViewController] is used for deleting the cookies (also session-only cookies) using JavaScript (cookies with `isHttpOnly` enabled cannot be deleted, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies)
  ///from the current context of the [WebView] managed by that controller when you need to target iOS below 11. JavaScript must be enabled in order to work.
  ///In this case the [url] parameter is ignored.
  ///
  ///**NOTE for iOS below 11.0**: If [iosBelow11WebViewController] is `null` or JavaScript is disabled for it, it will try to use a [HeadlessInAppWebView]
  ///to delete the cookies (session-only cookies and cookies with `isHttpOnly` enabled won't be deleted!).
  Future<void> deleteCookies({
    required Uri url,
    String domain = "",
    String path = "/",
  }) async {
    if (domain.isEmpty) domain = _getDomainName(url);

    assert(url.toString().isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url.toString());
    args.putIfAbsent('domain', () => domain);
    args.putIfAbsent('path', () => path);
    await _channel.invokeMethod('deleteCookies', args);
  }

  ///Removes all cookies.
  ///
  ///**NOTE for iOS**: available from iOS 11.0+.
  Future<void> deleteAllCookies() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('deleteAllCookies', args);
  }

  ///Fetches all stored cookies.
  ///
  ///**NOTE**: available on iOS 11.0+.
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882005-getallcookies
  Future<List<Cookie>> getAllCookies() async {
    List<Cookie> cookies = [];

    Map<String, dynamic> args = <String, dynamic>{};
    List<dynamic> cookieListMap =
        await _channel.invokeMethod('getAllCookies', args);
    cookieListMap = cookieListMap.cast<Map<dynamic, dynamic>>();

    cookieListMap.forEach((cookieMap) {
      cookies.add(Cookie(
          name: cookieMap["name"],
          value: cookieMap["value"],
          expiresDate: cookieMap["expiresDate"],
          isSessionOnly: cookieMap["isSessionOnly"],
          domain: cookieMap["domain"],
          sameSite: HTTPCookieSameSitePolicy.fromValue(cookieMap["sameSite"]),
          isSecure: cookieMap["isSecure"],
          isHttpOnly: cookieMap["isHttpOnly"],
          path: cookieMap["path"]));
    });
    return cookies;
  }

  String _getDomainName(Uri url) {
    String domain = url.host;
    return domain.startsWith("www.") ? domain.substring(4) : domain;
  }
}
