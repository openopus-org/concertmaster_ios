//
//  SceneDelegate.swift
//  Concertmaster
//
//  Created by Adriano Brandao on 29/01/20.
//  Copyright © 2020 Open Opus. All rights reserved.
//

import UIKit
import SwiftUI
import AVFoundation

class SceneDelegate: UIResponder, UIWindowSceneDelegate, SPTAppRemoteDelegate, SPTSessionManagerDelegate, SPTAppRemotePlayerStateDelegate {
    
    var window: UIWindow?
        
    var appState = AppState()
    var settingStore = SettingStore()
    var playState = PlayState()
    var radioState = RadioState()
    var previewBridge = PreviewBridge()
    var bgPlayer = BGPlayer()
    
    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: AppConstants.SpotifyClientID, redirectURL: AppConstants.SpotifyRedirectURL)
        configuration.playURI = AppConstants.SpotifySilentPlaylist
        configuration.tokenSwapURL = URL(string: AppConstants.concTokenAPI)
        configuration.tokenRefreshURL = URL(string: AppConstants.concTokenAPI)
        return configuration
    }()

    lazy var sessionManager: SPTSessionManager = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        return manager
    }()

    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .none)
        appRemote.delegate = self
        
        return appRemote
    }()
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
          guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL,
            let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else {
              return
          }
        
        let comps = components.path!.components(separatedBy: "/")
        
        if comps[1] == "r" {
            
            if let shortId = UInt32(comps[2], radix: 16) {
                APIget(AppConstants.concBackend+"/recording/unshorten/\(shortId).json") { results in
                    if let recordingData: ShortRecordingDetail = safeJSON(results) {
                        DispatchQueue.main.async {
                            self.appState.externalUrl = [recordingData.recording.work_id ?? "0", recordingData.recording.spotify_albumid ?? "0", recordingData.recording.set ?? "0"]
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.appState.externalUrl = ["0", "0", "0"]
                        }
                    }
                }
            }
        } else if comps[1] == "u" {
            DispatchQueue.main.async {
                self.appState.externalUrl = [comps[2], comps[3], comps[4]]
            }
        }
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
        let contentView = Structure()
                            .environment(\.colorScheme, .dark)
                            .environmentObject(appState)
                            .environmentObject(ComposerSearchString())
                            .environmentObject(OmnisearchString())
                            .environmentObject(WorkSearch())
                            .environmentObject(playState)
                            .environmentObject(TimerHolder())
                            .environmentObject(settingStore)
                            .environmentObject(radioState)
                            .environmentObject(previewBridge)
                            .environmentObject(bgPlayer)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.overrideUserInterfaceStyle = .dark
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
        
        if let userActivity = connectionOptions.userActivities.first {
            DispatchQueue.main.async {
                self.scene(scene, continue: userActivity)
            }
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }

        self.sessionManager.application(UIApplication.shared, open: url, options: [:])
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
        if let _ = self.appRemote.connectionParameters.accessToken {
            if !playState.logAndPlay {
                //self.appRemote.connect()
            }
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        
        if !playState.logAndPlay {
           // self.appRemote.disconnect()
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        //
        
        print ("⛔️ AppRemote error when connecting")
        print ("log and play - ", playState.logAndPlay)
        print ("has the token - ", !self.settingStore.accessToken.isEmpty)
        
        if self.playState.forceConnection {
            self.playState.logAndPlay = false
            self.playState.forceConnection = false
            self.sessionManager.initiateSession(with: AppConstants.SpotifyAuthScopes, options: .default)
        } else {
            //self.radioState.isActive = false
            
            if let firstrecording = self.playState.recording.first {
                if let tracks = firstrecording.tracks {
                    if let track = tracks.first {
                        self.playState.playerstate = PlayerState (isConnected: false, isPlaying: false, trackId: track.spotify_trackid, position: 0)
                        
                        // playing the music
                        
                        if playState.logAndPlay && !self.settingStore.accessToken.isEmpty {
                            
                            print("playing directly through the API, without the AppRemote working")
                              
                            APIBearerGet("\(AppConstants.SpotifyAPI)/me/player/devices", bearer: self.settingStore.accessToken) { results in
                                print(String(decoding: results, as: UTF8.self))
                                if let devicesData: Devices = safeJSON(results) {
                                    devicesData.devices.forEach() {
                                        if $0.is_active {
                                            self.settingStore.deviceId = $0.id
                                            print ("device id \($0.id)")
                                                    
                                            APIBearerPut("\(AppConstants.SpotifyAPI)/me/player/play?device_id=\($0.id)", body: "{ \"uris\": \(self.radioState.nextRecordings.count > 0 || self.radioState.nextWorks.count > 0 ? self.playState.recording.first!.jsonRadioTracks : self.playState.recording.first!.jsonTracks), \"offset\": { \"position\": 0 } }", bearer: self.settingStore.accessToken) { results in
                                                
                                                //print(String(decoding: results, as: UTF8.self))
                                                
                                                DispatchQueue.main.async {
                                                    self.bgPlayer.play()
                                                    print("log and play, auto play = false")
                                                    self.playState.autoplay = false
                                                    self.playState.logAndPlay = false
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                self.playState.playerstate = PlayerState (isConnected: false, isPlaying: false, trackId: "", position: 0)
            }
        }
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        //
        
        print ("⛔️ AppRemote disconnected")
        
        self.appRemote.connect()
    }
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        
        print("🎆 CONNECTION ESTABLISHED WITH THE SPOTIFY APP! 🎉")
        
        self.playState.forceConnection = false
        self.appRemote.playerAPI?.delegate = self
        
        // subscribe to the player state
        
        if !self.playState.isSubscribed || true {
            self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
              if let error = error {
                print("😱 ERROR SUBSCRIBING TO THE PLAYER STATE")
                debugPrint(error.localizedDescription)
              } else {
                self.playState.isSubscribed = true
              }
            })
        }
        
        // set shuffle/repeat off
        
        self.appRemote.playerAPI?.setShuffle(false, callback: {_,_ in
            print("shuffle off")
        })
        self.appRemote.playerAPI?.setRepeatMode(.off, callback: { (_, _) in
            print("repeat off")
        })
        
        // say hi to spotify every 4 minutes
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4 * 60) {
            self.appRemote.connect()
        }
        
        // playing the music
        
        if playState.logAndPlay {
            self.appRemote.playerAPI?.getPlayerState({ (result, error) in
                print("log and play: checking current playstate")
                
                if error == nil {
                    let currplayer = result as! SPTAppRemotePlayerState
                    print("playing ", currplayer.track.uri)
                    
                    APIBearerGet("\(AppConstants.SpotifyAPI)/me/player/devices", bearer: self.settingStore.accessToken) { results in
                        print(String(decoding: results, as: UTF8.self))
                        if let devicesData: Devices = safeJSON(results) {
                            devicesData.devices.forEach() {
                                if $0.is_active {
                                    self.settingStore.deviceId = $0.id
                                    print ("device id \($0.id)")
                                    
                                    if self.settingStore.lastPlayState.count > 0 {
                                        if self.settingStore.lastPlayState.first!.spotify_tracks!.firstIndex(of: currplayer.track.uri) == nil {
                                            
                                            APIBearerPut("\(AppConstants.SpotifyAPI)/me/player/play?device_id=\($0.id)", body: "{ \"uris\": \(self.radioState.nextRecordings.count > 0 || self.radioState.nextWorks.count > 0 ? self.playState.recording.first!.jsonRadioTracks : self.playState.recording.first!.jsonTracks), \"offset\": { \"position\": 0 } }", bearer: self.settingStore.accessToken) { results in
                                                
                                                //print(String(decoding: results, as: UTF8.self))
                                                
                                                DispatchQueue.main.async {
                                                    self.bgPlayer.play()
                                                    print("log and play, auto play = false")
                                                    self.playState.autoplay = false
                                                    self.playState.logAndPlay = false
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            })
        }
    }
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        if !playerState.track.uri.isEmpty {
            let newplaystate = PlayerState (isConnected: true, isPlaying: !playerState.isPaused, trackId: playerState.track.uri, position: Int(ceil(Double(playerState.playbackPosition/1000))))
            
            if self.playState.lastPlayerState != newplaystate || true {
                print("⚠️ CHANGED PLAYER STATE = ", playerState.track.uri)
                print("current time = ", playerState.playbackPosition/1000)
                self.playState.playerstate = newplaystate
                self.playState.lastPlayerState = newplaystate
            }
        }
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
      print("fail", error)
    }
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("🎉🎉🎉 session renewed!", session)
        appRemote.connectionParameters.accessToken = session.accessToken
        self.settingStore.accessToken = session.accessToken
        self.settingStore.refreshToken = session.refreshToken
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 30 * 60) {
            // renew the token before it expires
            self.sessionManager.renewSession()
        }
        
        /*
        print ("access token - \(session.accessToken)")
        print ("refresh token - \(session.refreshToken)")
        
        appRemote.connectionParameters.accessToken = session.accessToken
        sessionManager.session?.setValue(session.accessToken, forKey: "accessToken")
        sessionManager.session?.setValue(session.refreshToken, forKey: "refreshToken")
        */
    }
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print ("access token - \(session.accessToken)")
        print ("refresh token - \(session.refreshToken)")
        
        appRemote.connectionParameters.accessToken = session.accessToken
        //sessionManager.session?.setValue(session.accessToken, forKey: "accessToken")
        //sessionManager.session?.setValue(session.refreshToken, forKey: "refreshToken")
        
        self.settingStore.accessToken = session.accessToken
        self.settingStore.refreshToken = session.refreshToken
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 30 * 60) {
            // renew the token before it expires
            self.sessionManager.renewSession()
        }
        
        if timeframe(timestamp: settingStore.lastLogged, minutes: self.settingStore.userType == "premium" ? AppConstants.minsToLogin : 0)  {
            APIpost("\(AppConstants.concBackend)/dyn/user/login/", parameters: ["token": session.accessToken ]) { results in
                print("👀 User logged in")
                //print(String(decoding: results, as: UTF8.self))
                
                if let login: Login = safeJSON(results) {
                    DispatchQueue.main.async {
                        self.settingStore.userId = login.user.id
                        self.settingStore.lastLogged = Int(Date().millisecondsSince1970 / (60 * 1000) | 0)
                        
                        if let auth = login.user.auth {
                            self.settingStore.userAuth = auth
                        }
                        
                        if let country = login.user.country {
                            self.settingStore.country = country
                        }
                        
                        if let favoritecomposers = login.favorite {
                            self.settingStore.favoriteComposers = favoritecomposers
                        }
                        
                        if let favoriteworks = login.works {
                            self.settingStore.favoriteWorks = favoriteworks
                        }
                        
                        if let composersfavoriteworks = login.composerworks {
                            self.settingStore.composersFavoriteWorks = composersfavoriteworks
                        }
                        
                        if let favoriterecordings = login.favoriterecordings {
                            self.settingStore.favoriteRecordings = favoriterecordings
                        }
                        
                        if let forbiddencomposers = login.forbidden {
                            self.settingStore.forbiddenComposers = forbiddencomposers
                        }
                        
                        if let playlists = login.playlists {
                            self.settingStore.playlists = playlists
                        }
                        
                        if let heavyuser = login.user.heavyuser {
                            if heavyuser == 1 {
                                if timeframe(timestamp: self.settingStore.lastAskedDonation, minutes: self.settingStore.hasDonated ? AppConstants.minsToAskDonationHasDonated : AppConstants.minsToAskDonation)  {
                                    self.settingStore.hasDonated = false
                                    self.appState.askDonation = true
                                } else if timeframe(timestamp: self.settingStore.lastLogged, minutes: AppConstants.minsToReview) {
                                    RequestAppStoreReview()
                                }
                            }
                        }
                        
                        if let product = login.user.product {
                            self.settingStore.userType = product
                            
                            if product != "premium" {
                                self.appState.showingWarning = true
                                self.appState.warningType = .notPremium
                                
                                // playing preview
                                
                                self.playState.preview = true
                                
                                if !self.playState.recording.first!.previewUrls.isEmpty {
                                    self.appState.noPreviewAvailable = false
                                    self.previewBridge.setQueueAndPlay(tracks: self.playState.recording.first!.previewUrls, starttrack: 0, autoplay: true, zeroqueue: false)
                                } else {
                                    self.previewBridge.emptyQueue()
                                    self.appState.noPreviewAvailable = true
                                }
                            } else {
                                self.appRemote.connect()
                            }
                        }
                    }
                }
            }
        } else if self.settingStore.userType == "premium" {
            print("🟢 premium already logged, connecting!")
            self.appRemote.connect()
        }
    }
}
