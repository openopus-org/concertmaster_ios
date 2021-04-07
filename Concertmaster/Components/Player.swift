//
//  Player.swift
//  Concertmaster
//
//  Created by Adriano Brandao on 29/01/20.
//  Copyright © 2020 Open Opus. All rights reserved.
//

import SwiftUI
import StoreKit
import MediaPlayer

struct Player: View {
    @State private var currentTrack = [CurrentTrack]()
    @EnvironmentObject var previewBridge: PreviewBridge
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var playState: PlayState
    @EnvironmentObject var timerHolder: TimerHolder
    @EnvironmentObject var settingStore: SettingStore
    @EnvironmentObject var radioState: RadioState
    @EnvironmentObject var bgPlayer: BGPlayer
    
    private var appRemote: SPTAppRemote? {
        get {
            return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote
        }
    }
    private var sessionManager: SPTSessionManager? {
        get {
            return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.sessionManager
        }
    }
    
    func playMusic() {
        if self.currentTrack.count > 0 && !self.playState.keepQueue {
            self.currentTrack[0].loading = true
        }
        
        if self.playState.autoplay {
            // logging in the session

            if self.settingStore.userId != "" {
                MarkPlayed(settingStore: self.settingStore, playState: self.playState) { results in
                    /*DispatchQueue.main.async {
                        self.settingStore.lastPlayedRecording = self.playState.recording
                    }*/
                }
            }
        }
        
        // ios now playing
        
        let center = MPNowPlayingInfoCenter.default()
        var songInfo = [String: AnyObject]()
        
        if self.playState.recording.first!.previewUrls.isEmpty {
            center.nowPlayingInfo = nil
        } else {
            if let cover = self.playState.recording.first!.cover {
                imageGet(url: cover) { img in
                    DispatchQueue.main.async {
                        songInfo[MPMediaItemPropertyArtist] = self.playState.recording.first!.work!.composer!.name as AnyObject
                        songInfo[MPMediaItemPropertyAlbumTitle] = self.playState.recording.first!.work!.title as AnyObject
                        songInfo[MPMediaItemPropertyArtwork] = img as AnyObject
                        
                        if center.nowPlayingInfo?.count ?? 0 > 0 {
                            songInfo[MPMediaItemPropertyPlaybackDuration] = center.nowPlayingInfo![MPMediaItemPropertyPlaybackDuration] as AnyObject?
                            songInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = center.nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] as AnyObject?
                            songInfo[MPNowPlayingInfoPropertyPlaybackRate] = center.nowPlayingInfo![MPNowPlayingInfoPropertyPlaybackRate] as AnyObject?
                        }
                        
                        center.nowPlayingInfo = songInfo
                    }
                }
            }
        }
        
        self.settingStore.lastPlayState = self.playState.recording
        
        // logging in to spotify and to concertmaster
        
        if (self.playState.autoplay) {
            
            if let firstrecording = self.playState.recording.first {
                if let firstrecordingtracks = firstrecording.tracks {
                    if let firsttrack = firstrecordingtracks.first {
                        
                        // current recording
                        
                        self.currentTrack = [CurrentTrack (
                            track_index: 0,
                            zero_index: 0,
                            playing: false,
                            loading: true,
                            starting_point: 0,
                            track_position: 0,
                            track_length: firsttrack.length,
                            full_position: 0,
                            full_length: firstrecording.length ?? 0,
                            preview: false,
                            id: (self.playState.recording.first!.spotify_tracks?.first!)!
                        )]
                        
                        // playing
                     
                        if self.playState.preview {
                            self.currentTrack[0].preview = true
                            
                            if !self.playState.recording.first!.previewUrls.isEmpty {
                                self.appState.noPreviewAvailable = false
                                self.previewBridge.setQueueAndPlay(tracks: self.playState.recording.first!.previewUrls, starttrack: 0, autoplay: true, zeroqueue: false)
                            } else {
                                self.previewBridge.emptyQueue()
                                self.appState.noPreviewAvailable = true
                            }
                        } else {
                            bgPlayer.play()
                            if UIApplication.shared.canOpenURL(URL(string: "spotify:")!) {
                                if (!self.appRemote!.isConnected) {
                                    self.playState.logAndPlay = true
                                    self.sessionManager?.initiateSession(with: AppConstants.SpotifyAuthScopes, options: .default)
                                } else {
                                    APIBearerPut("\(AppConstants.SpotifyAPI)/me/player/play?device_id=\(self.settingStore.deviceId)", body: "{ \"uris\": \(self.radioState.nextRecordings.count > 0 ? self.playState.recording.first!.jsonRadioTracks : self.playState.recording.first!.jsonTracks), \"offset\": { \"position\": 0 } }", bearer: self.settingStore.accessToken) { results in
                                        //print(String(decoding: results, as: UTF8.self))
                                        
                                        DispatchQueue.main.async {
                                            //print("🙄 trying to renew session")
                                            //self.sessionManager?.renewSession()
                                            self.playState.autoplay = false
                                            if let _ = self.appRemote!.connectionParameters.accessToken {
                                                self.appRemote!.connect()
                                            }
                                        }
                                    }
                                }
                            } else {
                                print("⚠️ Spotify not installed on device!")
                                
                                self.appState.showingWarning = true
                                self.appState.warningType = .notInstalled
                                
                                // playing preview
                                
                                self.playState.preview = true
                                
                                if !self.playState.recording.first!.previewUrls.isEmpty {
                                    self.appState.noPreviewAvailable = false
                                    self.previewBridge.setQueueAndPlay(tracks: self.playState.recording.first!.previewUrls, starttrack: 0, autoplay: true, zeroqueue: false)
                                } else {
                                    self.previewBridge.emptyQueue()
                                    self.appState.noPreviewAvailable = true
                                }
                            }
                        }
                        
                        // radio? define the next recording
                        
                        if self.radioState.nextWorks.count > 0 {
                            
                            // random works
                            
                            DispatchQueue.main.async {
                                print("🔄 Radio ON, fetching a random recording!")
                                
                                if let indexPlayed = self.radioState.nextWorks.firstIndex(where: { $0.id == self.playState.recording.first!.work!.id }) {
                                    self.radioState.nextWorks = Array(self.radioState.nextWorks.suffix(from: indexPlayed+1))
                                }
                                
                                if self.radioState.nextWorks.count > 0 {
                                    randomRecording(workQueue: self.radioState.nextWorks, hideIncomplete:  self.settingStore.hideIncomplete, country: self.settingStore.country) { rec in
                                        if rec.count > 0 {
                                            DispatchQueue.main.async {
                                                self.radioState.nextRecordings[0] = rec.first!
                                                self.radioState.canSkip = true
                                            }
                                        }
                                        else {
                                            DispatchQueue.main.async {
                                                self.radioState.isActive = false
                                            }
                                        }
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        self.radioState.isActive = false
                                    }
                                }
                            }
                        } else if self.radioState.nextRecordings.count > 0 {
                            
                            // playlist
                            
                            print("⏭ Radio ON, fetching the next recording details!")
                            
                            getRecordingDetail(recording: self.radioState.nextRecordings.first!, country: self.settingStore.country) { recordingData in
                                if recordingData.count > 0 {
                                    DispatchQueue.main.async {
                                        self.radioState.nextRecordings[0] = recordingData.first!
                                        self.radioState.canSkip = true
                                    }
                                } else {
                                    print("Couldn't find the next recording")
                                    self.radioState.isActive = false
                                }
                            }
                        } else if self.radioState.isActive {
                            DispatchQueue.main.async {
                                self.radioState.isActive = false
                            }
                        }
                    }
                }
            }
        } else if !self.settingStore.accessToken.isEmpty && !timeframe(timestamp: settingStore.lastLogged, minutes: AppConstants.minsToToken) {
            // opening concertmaster but with a token recently defined
            
            if let firstrecording = self.playState.recording.first {
                if let firstrecordingsptracks = firstrecording.spotify_tracks {
                    APIBearerGet("\(AppConstants.SpotifyAPI)/me/player/", bearer: self.settingStore.accessToken) { results in
                        //print(String(decoding: results, as: UTF8.self))
                        
                        if !results.isEmpty {
                            if let player: SpotifyPlayer = safeJSON(results) {
                                if let item = player.item {
                                    if firstrecordingsptracks.firstIndex(of: item.uri) != nil {
                                        // playing the last played recording on Spotify
                                        
                                        print("🟢 the last recording is being played right now")
                                        
                                        if let firstrecordingtracks = firstrecording.tracks {
                                            if let firsttrack = firstrecordingtracks.first {
                                                
                                                DispatchQueue.main.async {
                                                    self.currentTrack = [CurrentTrack (
                                                        track_index: 0,
                                                        zero_index: 0,
                                                        playing: false,
                                                        loading: false,
                                                        starting_point: 0,
                                                        track_position: 0,
                                                        track_length: firsttrack.length,
                                                        full_position: 0,
                                                        full_length: firstrecording.length ?? 0,
                                                        preview: false,
                                                        id: (self.playState.recording.first!.spotify_tracks?.first!)!
                                                    )]
                                                    
                                                    self.playState.playerstate = PlayerState (isConnected: false, isPlaying: false, trackId: "", position: 0)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(Color(hex: 0xFCE546))
                .frame(minHeight: 130, maxHeight: self.appState.fullPlayer ? .infinity : 130)

            VStack {
                Button(
                    action: { self.appState.fullPlayer.toggle() },
                    label: {
                        HStack {
                            Spacer()
                            
                            Image("handle")
                                .resizable()
                                .frame(width: 7, height: 32)
                                .foregroundColor(Color(hex: 0x696969))
                                .rotationEffect(.degrees(self.appState.fullPlayer ? 90 : 270))
                            
                            Spacer()
                        }
                    })
                    .frame(height: 7)
                    .padding(.top, (self.appState.fullPlayer ? 14 : 10))
                    
                if (playState.recording.count > 0) {
                    if self.appState.fullPlayer {
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading) {
                                RecordingWorkPerformers(recording: playState.recording.first!, isSheet: false, isPlayer: true)
                                    .padding(.bottom, 30)
                                RecordingProgressBars(recording: playState.recording.first!, currentTrack: $currentTrack)
                                
                                if self.currentTrack.count > 0 {
                                    if self.playState.preview {
                                        HStack {
                                            Spacer()
                                            
                                            HStack {
                                                BrowseOnlyMode(size: "max")
                                            }
                                            .padding(.top, 12)
                                            .padding(.bottom, 6)
                                            .padding(.leading, 12)
                                            .padding(.trailing, 18)
                                            //.background(Color.black)
                                            //.cornerRadius(24)
                                            .opacity(0.8)
                                            
                                            Spacer()
                                        }
                                        .padding(.top, 10)
                                    }
                                }
                            }
                            .padding(30)
                            .padding(.top, -16)
                        }
                        .padding(.top, 0)

                        Spacer()
                        
                        if !self.appState.noPreviewAvailable {
                            RecordingPlaybackControl(currentTrack: $currentTrack)
                        } else {
                            PreviewNotAvailable(size: "max")
                        }
                    }
                    else {
                        RecordingMini(recording: playState.recording.first!, currentTrack: $currentTrack)
                            .padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
                    }
                }
            }
        }
        .padding(EdgeInsets(top: UIDevice.current.isLarge ? 28 : 0, leading: 0, bottom: UIDevice.current.isLarge ? 46 : 40, trailing: 0))
        .clipped()
        .onAppear(perform: {
            if (self.currentTrack.count == 0 && self.settingStore.lastPlayState.count > 0) {
                self.playState.autoplay = false
                self.playState.recording = self.settingStore.lastPlayState
            }
        })
        .onReceive(playState.playerstateDidChange, perform: {
            
            appRemote?.playerAPI?.getPlayerState({ result, error in
                //dump(result)
            })
            
            if self.currentTrack.count > 0 {
                
                if let playerstate = playState.playerstate {
                        
                    if playerstate.isConnected {
                        if let trackIndex = self.playState.recording.first!.spotify_tracks!.firstIndex(of: playerstate.trackId) {
                            
                            print("radio state: \(self.radioState.isActive)")
                            
                            if trackIndex == 0 {
                                self.currentTrack[0].zero_index = 0
                            }
                            
                            self.currentTrack[0].track_index = trackIndex
                            self.currentTrack[0].track_position = playerstate.position
                            self.currentTrack[0].starting_point = (self.playState.recording.first!.tracks![trackIndex - self.currentTrack[0].zero_index].starting_point)
                            self.currentTrack[0].full_position = (self.playState.recording.first!.tracks![trackIndex - self.currentTrack[0].zero_index].starting_point)
                            self.currentTrack[0].track_length = (self.playState.recording.first!.tracks![trackIndex - self.currentTrack[0].zero_index].length)
                            
                            if playerstate.isPlaying {
                                    print("🆗 started")
                                    self.currentTrack[0].loading = false
                                    self.timerHolder.start()
                            }
                            else {
                                self.currentTrack[0].loading = false
                                print("⛔️ stopped")
                                self.timerHolder.stop()
                            }
                            
                            self.currentTrack[0].playing = playerstate.isPlaying
                            print("⏯ playing: ", playerstate.isPlaying)
                            dump(self.currentTrack)
                        } else {
                            print("log and play ", self.playState.logAndPlay)
                            print("auto play ", self.playState.autoplay)
                            if !self.playState.logAndPlay && !self.playState.autoplay && playerstate.trackId != AppConstants.SpotifySilentTrack {
                                print("🔴 Not the right recording: ", playerstate.trackId)
                                /*
                                print("Should be any of:")
                                dump(self.playState.recording.first!.spotify_tracks)
                                self.currentTrack = [CurrentTrack]()
                                self.timerHolder.stop()
                                */
                                
                                self.timerHolder.stop()
                                self.playState.playerstate = PlayerState (isConnected: false, isPlaying: false, trackId: "", position: 0)
                                self.currentTrack = [CurrentTrack]()
                            }
                        }
                    } else {
                        // not connected anymore
                        
                        if let firsttrack = self.currentTrack.first {
                            if firsttrack.playing {
                                self.timerHolder.stop()
                                
                                self.currentTrack[0].playing = false
                                self.currentTrack[0].track_position = 0
                                self.currentTrack[0].full_position = 0
                            }
                        }
                    }
                }
            }
        })
        .onReceive(playState.objectWillChange, perform: {
            if let firstrecording = self.playState.recording.first {
                if firstrecording.tracks != nil {
                    print("playmusic()")
                    self.playMusic()
                }
            }
        })
        .onReceive(timerHolder.objectWillChange, perform: {
            if (self.currentTrack.count > 0) {
                
                if self.playState.preview {
                    self.currentTrack[0].track_position = self.previewBridge.getCurrentPlaybackTime()
                } else {
                    self.currentTrack[0].track_position += 1
                    
                    if let currenttrack = self.currentTrack.first {
                        if let firstrecording = self.playState.recording.first {
                            if let firstrecordingtracks = firstrecording.tracks {
                                if currenttrack.track_index == firstrecordingtracks.count - 1 {
                                    
                                    // last track
                                    
                                    if currenttrack.track_position == currenttrack.track_length + 2 {
                                        print("🚨🚨🚨🚨🚨🚨 LAST TRACK 🚨🚨🚨🚨🚨🚨")
                                        
                                        if self.radioState.nextRecordings.count > 0 {
                                            print("⏭ Radio ON, playing the next recording!")
                                            
                                            if self.playState.preview {
                                                self.previewBridge.stop()
                                            }
                                            
                                            self.playState.autoplay = true
                                            self.currentTrack[0].track_position = 0
                                            self.playState.recording = [self.radioState.nextRecordings.removeFirst()]
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                if self.currentTrack[0].track_position < 2 {
                    if self.playState.preview {
                        self.currentTrack[0].playing = self.previewBridge.getCurrentPlaybackState()
                    } else {
                        if let playerstate = playState.playerstate {
                            if !playerstate.isPlaying {
                                self.currentTrack[0].track_position = playerstate.position
                            }
                        }
                    }
                    
                    self.playState.playing = self.currentTrack[0].playing
                }  
                
                self.currentTrack[0].full_position = self.currentTrack[0].starting_point + self.currentTrack[0].track_position
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name.previewPlayerItemChanged)) { status in
            print("New track: \(self.previewBridge.getCurrentTrackIndex())")
            
            if self.currentTrack.count > 0 {
                self.currentTrack[0].preview = true
                let trackIndex = self.previewBridge.getCurrentTrackIndex()
                
                print("radio state: \(self.radioState.isActive)")
                
                if trackIndex == 0 {
                    self.currentTrack[0].zero_index = 0
                }
                
                self.currentTrack[0].track_index = trackIndex
                self.currentTrack[0].track_position = 0
                self.currentTrack[0].starting_point = (self.playState.recording.first!.tracks![trackIndex - self.currentTrack[0].zero_index].starting_point)
                self.currentTrack[0].full_position = (self.playState.recording.first!.tracks![trackIndex - self.currentTrack[0].zero_index].starting_point)
                self.currentTrack[0].track_length = (self.playState.recording.first!.tracks![trackIndex - self.currentTrack[0].zero_index].length)
                
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name.previewPlayerStatusChanged)) { status in
            if self.currentTrack.count > 0 {
                if let isPlaying = status.userInfo?["status"] as? String {
                    
                    // removing loading
                    
                    if isPlaying  == "playing" {
                        print("🆗 started")
                        self.currentTrack[0].loading = false
                        self.timerHolder.start()
                    }
                    else if isPlaying == "paused" {
                        self.currentTrack[0].loading = false
                        print("⛔️ stopped")
                        self.timerHolder.stop()
                    }
                    
                    self.currentTrack[0].playing = (isPlaying == "playing")
                    self.playState.playing = (isPlaying == "playing")
                }
            }
        }
        
    }
}

struct Player_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
