//
//  YouTubePlayerView.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 12/09/26.
//

import SwiftUI
import WebKit

struct YouTubePlayerView: UIViewRepresentable {
    struct SeekRequest: Equatable {
        let seconds: Int
        let token: Int
    }

    let holder: YouTubePlayerHolder
    let videoID: String
    let seekRequest: SeekRequest?
    let isActive: Bool

    private static let origin = "https://www.dapurnaura.id"
    private static let playerPath = "/player.html"

    func makeUIView(context: Context) -> WKWebView {
        guard holder.loadedVideoID != videoID else { return holder.webView }
        holder.loadedVideoID = videoID
        Self.load(holder.webView, startAt: nil, videoID: videoID)
        return holder.webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if holder.wasActive != isActive {
            holder.wasActive = isActive
            if !isActive {
                Task { _ = try? await webView.evaluateJavaScript("pauseIfPlaying();") }
            }
        }

        guard let request = seekRequest, request.token != holder.lastToken else { return }
        holder.lastToken = request.token

        Task {
            let result = try? await webView.evaluateJavaScript("seekTo(\(request.seconds));")
            guard (result as? Bool) != true else { return }
            Self.load(webView, startAt: request.seconds, videoID: videoID)
        }
    }

    private static func load(_ webView: WKWebView, startAt seconds: Int?, videoID: String) {
        guard let url = URL(string: origin + playerPath) else { return }
        webView.loadSimulatedRequest(
            URLRequest(url: url),
            responseHTML: playerHTML(videoID: videoID, startAt: seconds)
        )
    }

    private static func playerHTML(videoID: String, startAt seconds: Int?) -> String {
        let startVars = seconds.map { "start: \($0), autoplay: 1," } ?? ""

        return """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
        <style>
            html, body { margin: 0; padding: 0; background: transparent; overflow: hidden; }
            #player { position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: 0; }
        </style>
        </head>
        <body>
        <div id="player"></div>
        <script src="https://www.youtube.com/iframe_api"></script>
        <script>
            var player;
            var pendingSeek = null;

            function onYouTubeIframeAPIReady() {
                player = new YT.Player('player', {
                    videoId: '\(videoID)',
                    playerVars: {
                        playsinline: 1,
                        rel: 0,
                        modestbranding: 1,
                        \(startVars)
                        origin: '\(origin)'
                    },
                    events: { onReady: onPlayerReady }
                });
            }

            function onPlayerReady() {
                if (pendingSeek === null) { return; }
                var seconds = pendingSeek;
                pendingSeek = null;
                seekTo(seconds);
            }

            function pauseIfPlaying() {
                try {
                    if (!player || typeof player.pauseVideo !== 'function') { return false; }
                    player.pauseVideo();
                    return true;
                } catch (error) {
                    return false;
                }
            }

            function seekTo(seconds) {
                try {
                    if (!player || typeof player.seekTo !== 'function') {
                        pendingSeek = seconds;
                        return false;
                    }
                    player.seekTo(seconds, true);
                    if (typeof player.playVideo === 'function') { player.playVideo(); }
                    return true;
                } catch (error) {
                    return false;
                }
            }
        </script>
        </body>
        </html>
        """
    }
}
