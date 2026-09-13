//
//  YouTubePlayerHolder.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 13/09/26.
//

import WebKit

@MainActor
final class YouTubePlayerHolder {
    lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        return webView
    }()

    var loadedVideoID: String?
    var lastToken: Int?
    var wasActive: Bool?
}
