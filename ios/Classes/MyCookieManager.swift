//
//  MyCookieManager.swift
//  flutter_inappwebview
//
//  Created by Lorenzo on 26/10/18.
//

import Foundation
import WebKit

@available(iOS 11.0, *)
class MyCookieManager: NSObject, FlutterPlugin {

    static var registrar: FlutterPluginRegistrar?
    static var channel: FlutterMethodChannel?

    static func register(with registrar: FlutterPluginRegistrar) {
        
    }
    
    init(registrar: FlutterPluginRegistrar) {
        super.init()
        MyCookieManager.registrar = registrar
        MyCookieManager.channel = FlutterMethodChannel(name: "com.pichillilorenzo/flutter_inappwebview_cookiemanager", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(self, channel: MyCookieManager.channel!)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        switch call.method {
            case "setCookie":
                WKWebsiteDataStore.default().setCookie(arguments: arguments, result: result)
                break
            case "getCookies":
                WKWebsiteDataStore.default().getCookies(arguments: arguments, result: result)
                break
            case "getAllCookies":
                WKWebsiteDataStore.default().getAllCookies(result: result)
                break
            case "deleteCookie":
                WKWebsiteDataStore.default().deleteCookie(arguments: arguments, result: result)
                break;
            case "deleteCookies":
                WKWebsiteDataStore.default().deleteCookies(arguments: arguments, result: result)
                break;
            case "deleteAllCookies":
                WKWebsiteDataStore.default().deleteAllCookies(result: result)
                break
            default:
                result(FlutterMethodNotImplemented)
                break
        }
    }
}
