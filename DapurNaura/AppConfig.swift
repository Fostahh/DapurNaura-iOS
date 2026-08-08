//
//  AppConfig.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 10/06/26.
//

import Foundation

enum AppConfig {
    static var baseURL: String {
        string(forKey: "BaseURL", placeholder: "$(API_BASE_URL)")
    }

    static var apiKey: String {
        string(forKey: "ApiKey", placeholder: "$(API_KEY)")
    }

    static var enableNetworkLogging: Bool {
        string(forKey: "EnableNetworkLogging", placeholder: "$(ENABLE_NETWORK_LOGGING)") == "YES"
    }
}

// MARK: - Reading
private extension AppConfig {
    static func string(forKey key: String, placeholder: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
              !value.isEmpty,
              value != placeholder else {
            fatalError("""
                \(key) is missing from Info.plist.

                Most likely DapurNaura/Config/Secrets.xcconfig does not exist.
                Create it with these two lines, then rebuild:

                    STAGING_API_KEY = ...
                    PROD_API_KEY = ...
                """)
        }
        return value
    }
}
