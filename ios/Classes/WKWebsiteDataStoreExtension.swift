//
//  CookieHandler.swift
//  flutter_inappwebview
//
//  Created by Heljas on 17/03/2021.
//

import Foundation
import WebKit

@available(iOS 11.0, *)
extension WKWebsiteDataStore {
        
    public func setCookie(arguments: NSDictionary?, result: @escaping FlutterResult) {
        
        let url = arguments!["url"] as! String
        let name = arguments!["name"] as! String
        let value = arguments!["value"] as! String
        let domain = arguments!["domain"] as! String
        let path = arguments!["path"] as! String
        
        var expiresDate: Int64?
        if let expiresDateString = arguments!["expiresDate"] as? String {
            expiresDate = Int64(expiresDateString)
        }
        
        let maxAge = arguments!["maxAge"] as? Int64
        let isSecure = arguments!["isSecure"] as? Bool
        let isHttpOnly = arguments!["isHttpOnly"] as? Bool
        let sameSite = arguments!["sameSite"] as? String
        
        var properties: [HTTPCookiePropertyKey: Any] = [:]
        properties[.originURL] = url
        properties[.name] = name
        properties[.value] = value
        properties[.domain] = domain
        properties[.path] = path
        if expiresDate != nil {
            // convert from milliseconds
            properties[.expires] = Date(timeIntervalSince1970: TimeInterval(Double(expiresDate!)/1000))
        }
        if maxAge != nil {
            properties[.maximumAge] = String(maxAge!)
        }
        if isSecure != nil && isSecure! {
            properties[.secure] = "TRUE"
        }
        if isHttpOnly != nil && isHttpOnly! {
            properties[.init("HttpOnly")] = "YES"
        }
        if sameSite != nil {
            if #available(iOS 13.0, *) {
                var sameSiteValue = HTTPCookieStringPolicy(rawValue: "None")
                switch sameSite {
                case "Lax":
                    sameSiteValue = HTTPCookieStringPolicy.sameSiteLax
                case "Strict":
                    sameSiteValue = HTTPCookieStringPolicy.sameSiteStrict
                default:
                    break
                }
                properties[.sameSitePolicy] = sameSiteValue
            } else {
                properties[.init("SameSite")] = sameSite
            }
        }
        
        let cookie = HTTPCookie(properties: properties)!
        
        httpCookieStore.setCookie(cookie, completionHandler: {() in
            result(true)
        })
    }
    
    public func getCookies(arguments: NSDictionary?, result: @escaping FlutterResult) {
        
        let url = arguments!["url"] as! String

        var cookieList: [[String: Any?]] = []
        
        if let urlHost = URL(string: url)?.host {
            httpCookieStore.getAllCookies { (cookies) in
                for cookie in cookies {
                    if urlHost.hasSuffix(cookie.domain) || ".\(urlHost)".hasSuffix(cookie.domain) {
                        var sameSite: String? = nil
                        if #available(iOS 13.0, *) {
                            if let sameSiteValue = cookie.sameSitePolicy?.rawValue {
                                sameSite = sameSiteValue.prefix(1).capitalized + sameSiteValue.dropFirst()
                            }
                        }
                        
                        var expiresDateTimestamp: Int64 = -1
                        if let expiresDate = cookie.expiresDate?.timeIntervalSince1970 {
                            // convert to milliseconds
                            expiresDateTimestamp = Int64(expiresDate * 1000)
                        }
                        
                        cookieList.append([
                            "name": cookie.name,
                            "value": cookie.value,
                            "expiresDate": expiresDateTimestamp != -1 ? expiresDateTimestamp : nil,
                            "isSessionOnly": cookie.isSessionOnly,
                            "domain": cookie.domain,
                            "sameSite": sameSite,
                            "isSecure": cookie.isSecure,
                            "isHttpOnly": cookie.isHTTPOnly,
                            "path": cookie.path,
                        ])
                    }
                }
                result(cookieList)
            }
            return
        } else {
            print("Cannot get WebView cookies. No HOST found for URL: \(url)")
        }
        
        result(cookieList)
    }
    
    public func getAllCookies(result: @escaping FlutterResult) {
        var cookieList: [[String: Any?]] = []
        
        httpCookieStore.getAllCookies { (cookies) in
            for cookie in cookies {
                var sameSite: String? = nil
                if #available(iOS 13.0, *) {
                    if let sameSiteValue = cookie.sameSitePolicy?.rawValue {
                        sameSite = sameSiteValue.prefix(1).capitalized + sameSiteValue.dropFirst()
                    }
                }
                
                var expiresDateTimestamp: Int64 = -1
                if let expiresDate = cookie.expiresDate?.timeIntervalSince1970 {
                    // convert to milliseconds
                    expiresDateTimestamp = Int64(expiresDate * 1000)
                }
                
                cookieList.append([
                    "name": cookie.name,
                    "value": cookie.value,
                    "expiresDate": expiresDateTimestamp != -1 ? expiresDateTimestamp : nil,
                    "isSessionOnly": cookie.isSessionOnly,
                    "domain": cookie.domain,
                    "sameSite": sameSite,
                    "isSecure": cookie.isSecure,
                    "isHttpOnly": cookie.isHTTPOnly,
                    "path": cookie.path,
                ])
            }
            result(cookieList)
        }
    }
    
    public func deleteCookie(arguments: NSDictionary?, result: @escaping FlutterResult) {
        
        let url = arguments!["url"] as! String
        let name = arguments!["name"] as! String
        let domain = arguments!["domain"] as! String
        let path = arguments!["path"] as! String
        
        
        httpCookieStore.getAllCookies { (cookies) in
            for cookie in cookies {
                var originURL = ""
                if cookie.properties![.originURL] is String {
                    originURL = cookie.properties![.originURL] as! String
                }
                else if cookie.properties![.originURL] is URL {
                    originURL = (cookie.properties![.originURL] as! URL).absoluteString
                }
                if (!originURL.isEmpty && originURL != url) {
                    continue
                }
                if (cookie.domain == domain || cookie.domain == ".\(domain)" || ".\(cookie.domain)" == domain) && cookie.name == name && cookie.path == path {
                    self.httpCookieStore.delete(cookie, completionHandler: {
                        result(true)
                    })
                    return
                }
            }
            result(false)
        }
    }
    
    public func deleteCookies(arguments: NSDictionary?, result: @escaping FlutterResult) {
        
        let url = arguments!["url"] as! String
        let domain = arguments!["domain"] as! String
        let path = arguments!["path"] as! String
        
        httpCookieStore.getAllCookies { (cookies) in
            for cookie in cookies {
                var originURL = ""
                if cookie.properties![.originURL] is String {
                    originURL = cookie.properties![.originURL] as! String
                }
                else if cookie.properties![.originURL] is URL{
                    originURL = (cookie.properties![.originURL] as! URL).absoluteString
                }
                if (!originURL.isEmpty && originURL != url) {
                    continue
                }
                if (cookie.domain == domain || cookie.domain == ".\(domain)" || ".\(cookie.domain)" == domain) && cookie.path == path {
                    self.httpCookieStore.delete(cookie, completionHandler: nil)
                }
            }
            result(true)
        }
    }
    
    public func deleteAllCookies(result: @escaping FlutterResult) {
        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeCookies])
        let date = NSDate(timeIntervalSince1970: 0)
        removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{
            result(true)
        })
    }
}
