//
//  RecordingProgressBars.swift
//  Concertmaster
//
//  Created by Adriano Brandao on 24/02/20.
//  Copyright © 2020 Open Opus. All rights reserved.
//

import SwiftUI

struct RecordingProgressBars: View {
    var recording: Recording
    @Binding var currentTrack: [CurrentTrack]
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var previewBridge: PreviewBridge
    @EnvironmentObject var playState: PlayState
    @EnvironmentObject var radioState: RadioState
    @EnvironmentObject var settingStore: SettingStore
    
    private var appRemote: SPTAppRemote? {
        get {
            return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote
        }
    }
    
    var body: some View {
        Group {
            if self.recording.tracks != nil {
                if self.currentTrack.count > 0 && !self.appState.noPreviewAvailable {
                    if let playerstate = playState.playerstate {
                        if playerstate.isConnected {
                            ForEach(self.recording.tracks!, id: \.id) { track in
                                VStack(alignment: .leading) {
                                    
                                    Button(action: {
                                        self.currentTrack[0].loading = true
                                        self.currentTrack[0].zero_index = 0
                                        
                                        if let offset = self.recording.tracks!.firstIndex(where: {$0.spotify_trackid == track.spotify_trackid}) {
                                            
                                            APIBearerPut("\(AppConstants.SpotifyAPI)/me/player/play?device_id=\(self.settingStore.deviceId)", body: "{ \"uris\": \(self.radioState.nextRecordings.count > 0 ? self.playState.recording.first!.jsonRadioTracks : self.playState.recording.first!.jsonTracks), \"offset\": { \"position\": \(offset) } }", bearer: self.settingStore.accessToken) { results in
                                                
                                                DispatchQueue.main.async {
                                                    print("TRACK CHANGED TO ", track.spotify_trackid)
                                                    self.playState.playerstate = PlayerState (isConnected: true, isPlaying: true, trackId: "spotify:track:\(track.spotify_trackid)", position: 0)
                                                    
                                                    if let _ = self.appRemote!.connectionParameters.accessToken {
                                                        self.appRemote!.connect()
                                                    }
                                                    
                                                    //print(String(decoding: results, as: UTF8.self))
                                                }
                                            }
                                        }
                                    }, label: {
                                        Text(track.title)
                                            .font(.custom("PetitaMedium", size: 14))
                                            .foregroundColor(Color.black)
                                    })
                                    
                                    RecordingProgressBar(track: track, currentTrack: self.$currentTrack)
                                }
                            }
                        } else {
                            RecordingTrackList(recording: self.recording, color: Color(.black))
                                .padding(.top, 10)
                        }
                    } else if self.playState.preview {
                        ForEach(self.recording.tracks!, id: \.id) { track in
                            VStack(alignment: .leading) {
                                
                                Button(action: {
                                    self.currentTrack[0].loading = true
                                    self.currentTrack[0].zero_index = 0
                                    
                                    self.previewBridge.stop()
                                    self.previewBridge.setQueueAndPlay(tracks: self.radioState.nextRecordings.count > 0 ? self.playState.recording.first!.previewUrls + self.radioState.nextRecordings.first!.previewUrls : self.playState.recording.first!.previewUrls, starttrack: self.recording.tracks!.firstIndex{$0.spotify_trackid == track.spotify_trackid} ?? 0, autoplay: true, zeroqueue: false)
                                    
                                }, label: {
                                    Text(track.title)
                                        .font(.custom("PetitaMedium", size: 14))
                                        .foregroundColor(Color.black)
                                })
                                
                                RecordingProgressBar(track: track, currentTrack: self.$currentTrack)
                            }
                        }
                    }
                } else {
                    RecordingTrackList(recording: self.recording, color: Color(.black))
                        .padding(.top, 10)
                }
            } else {
                HStack {
                    Spacer()
                    ActivityIndicator(isAnimating: true)
                        .configure { $0.color = .black; $0.style = .large }
                    Spacer()
                }
                .padding(.top, 30)
            }
        }
    }
}

struct RecordingProgressBars_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
