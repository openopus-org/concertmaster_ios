//
//  Inc.swift
//  Concertmaster
//
//  Created by Adriano Brandao on 01/02/20.
//  Copyright © 2020 Open Opus. All rights reserved.
//

import Foundation

struct AppConstants {
    static let version = "1.20.1202 alpha"
    static let openOpusBackend = "https://api.openopus.org"
    static let concBackend = "https://beta.api.concertmaster.app"
    static let concFrontend = "https://concertmaster.app"
    static let concShortFrontend = "https://cmas.me/r"
    static let concNoCoverImg = concFrontend + "/img/nocover.png"
    static let genreList = ["Chamber", "Keyboard", "Orchestral", "Stage", "Vocal"]
    static let periodList = ["Medieval", "Renaissance", "Baroque", "Classical", "Early Romantic", "Romantic", "Late Romantic", "20th Century", "Post-War", "21st Century"]
    static let groupList = ["Orchestra", "Choir", "Ensemble"]
    static let maxPerformers = 5
    static let mainPerformersList = ["Orchestra", "Ensemble", "Piano", "Conductor", "Violin", "Cello"]
    static let spotifyLink = "https://open.spotify.com/album/"
    static let strucTopPadding = 50
    static let strucTopPadding14Offset = 50
    static let strucTopPaddingNoNotchOffset = 45
    static let strucTopPaddingSmallOffset = 10
    static let strucTopPaddingiPad14Offset = 0
    static let inAppPurchases = ["org.openopus.concertmaster.ios.tip", "org.openopus.concertmaster.ios.vgtip", "org.openopus.concertmaster.ios.sgtip"]
    static let minsToAskDonation = 7 * 24 * 60
    static let minsToAskDonationHasDonated = 30 * 24 * 60
    static let minsToLogin = 2 * 60
    static let minsToToken = 4 * 60
    static let SpotifyClientID = "d51f903ebcac46d9a036b4a2da05b299"
    static let SpotifyRedirectURL = URL(string: "concertmaster-app://spotify-login-callback")!
    static let concTokenAPI = "https://api.concertmaster.app/dyn/token/"
    static let SpotifyAuthScopes: SPTScope = [.appRemoteControl, .userReadPlaybackState, .userModifyPlaybackState, .userReadCurrentlyPlaying, .streaming, .userReadEmail, .userReadPrivate]
    static let SpotifySilentTrack = "spotify:track:647hR0e3Rp07l8MtPSMu2s"
    static let SpotifyAPI = "https://api.spotify.com/v1"
}
