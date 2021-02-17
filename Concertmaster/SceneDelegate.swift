//
//  SceneDelegate.swift
//  Concertmaster
//
//  Created by Adriano Brandao on 29/01/20.
//  Copyright © 2020 Open Opus. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate, SPTAppRemoteDelegate, SPTSessionManagerDelegate {
    
    var window: UIWindow?
    
    lazy var appState = AppState()
    let settingStore = SettingStore()
    
    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: AppConstants.SpotifyClientID, redirectURL: AppConstants.SpotifyRedirectURL)
        configuration.playURI = AppConstants.SpotifySilentTrack
        configuration.tokenSwapURL = URL(string: AppConstants.concTokenAPI)
        configuration.tokenRefreshURL = URL(string: AppConstants.concTokenAPI)
        return configuration
    }()

    lazy var sessionManager: SPTSessionManager = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        return manager
    }()

    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
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
                            .environmentObject(PlayState())
                            .environmentObject(TimerHolder())
                            .environmentObject(MediaBridge())
                            .environmentObject(SettingStore())
                            .environmentObject(RadioState())
                            .environmentObject(PreviewBridge())

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
        
        appRemote.connect()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
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
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        //
    }
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        //
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
      print("fail", error)
    }
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
      print("renewed", session)
    }
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print ("access token - \(session.accessToken)")
        appRemote.connectionParameters.accessToken = session.accessToken
        self.settingStore.accessToken = session.accessToken
        appRemote.connect()
        
        APIpost("\(AppConstants.concBackend)/dyn/user/login/", parameters: ["token": session.accessToken ]) { results in
            print("👀 User details 👇🏻")
            print(String(decoding: results, as: UTF8.self))
            
            if let login: Login = safeJSON(results) {
                DispatchQueue.main.async {
                    self.settingStore.userId = login.user.id
                    self.settingStore.lastLogged = Int(Date().millisecondsSince1970 / (60 * 1000) | 0)
                    
                    if let auth = login.user.auth {
                        self.settingStore.userAuth = auth
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
                    
                    /*
                    if let heavyuser = login.user.heavyuser {
                        if heavyuser == 1 {
                            if timeframe(timestamp: settingStore.lastAskedDonation, minutes: self.settingStore.hasDonated ? AppConstants.minsToAskDonationHasDonated : AppConstants.minsToAskDonation)  {
                                self.settingStore.hasDonated = false
                                self.AppState.askDonation = true
                            } else {
                                RequestAppStoreReview()
                            }
                        }
                    }
                    */
                }
            }
            
            if self.settingStore.deviceId == "" {
                APIBearerGet("\(AppConstants.SpotifyAPI)/me/player/devices", bearer: session.accessToken) { results in
                    print(String(decoding: results, as: UTF8.self))
                    if let devicesData: Devices = safeJSON(results) {
                        devicesData.devices.forEach() {
                            if $0.is_active {
                                self.settingStore.deviceId = $0.id
                                print ("device id \($0.id)")
                                
                                if self.settingStore.lastPlayState.count > 0 {
                                    APIBearerPut("\(AppConstants.SpotifyAPI)/me/player/play?device_id=\($0.id)", body: "{ \"uris\": \(self.settingStore.lastPlayState.first!.jsonTracks), \"offset\": { \"position\": 0 } }", bearer: self.settingStore.accessToken) { results in
                                        print(String(decoding: results, as: UTF8.self))
                                    }
                                }
                            }
                        }
                    }
                }
            } else if self.settingStore.lastPlayState.count > 0 {
                APIBearerPut("\(AppConstants.SpotifyAPI)/me/player/play?device_id=\(self.settingStore.deviceId)", body: "{ \"uris\": \(self.settingStore.lastPlayState.first!.jsonTracks), \"offset\": { \"position\": 0 } }", bearer: self.settingStore.accessToken) { results in
                    print(String(decoding: results, as: UTF8.self))
                }
            }
        }
    }
}

