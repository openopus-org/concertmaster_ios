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
    @EnvironmentObject var mediaBridge: MediaBridge
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
                if self.currentTrack.count > 0 {
                    ForEach(self.recording.tracks!, id: \.id) { track in
                        VStack(alignment: .leading) {
                            
                            Button(action: {
                                self.currentTrack[0].loading = true
                                self.currentTrack[0].zero_index = 0
                                
                                if self.currentTrack.first!.preview {
                                    self.previewBridge.stop()
                                    self.previewBridge.setQueueAndPlay(tracks: self.radioState.nextRecordings.count > 0 ? self.playState.recording.first!.previews! + self.radioState.nextRecordings.first!.previews! : self.playState.recording.first!.previews!, starttrack: self.recording.tracks!.firstIndex{$0.spotify_trackid == track.spotify_trackid} ?? 0, autoplay: true, zeroqueue: false)
                                } else {
                                    if let offset = self.recording.tracks!.firstIndex(where: {$0.spotify_trackid == track.spotify_trackid}) {
                                        
                                        APIBearerPut("\(AppConstants.SpotifyAPI)/me/player/play?device_id=\(self.settingStore.deviceId)", body: "{ \"uris\": \(self.playState.recording.first!.jsonTracks), \"offset\": { \"position\": \(offset) } }", bearer: self.settingStore.accessToken) { results in
                                            
                                            self.playState.playerstate = PlayerState (isLoaded: true, isPlaying: true, trackId: track.spotify_trackid, position: 0)
                                            
                                            print(String(decoding: results, as: UTF8.self))
                                        }
                                    }
                                    /*
                                    self.mediaBridge.stop()
                                    self.mediaBridge.setQueueAndPlay(tracks: self.radioState.nextRecordings.count > 0 ? self.playState.recording.first!.spotify_tracks! + self.radioState.nextRecordings.first!.spotify_tracks! : self.playState.recording.first!.spotify_tracks!, starttrack: track.spotify_trackid, autoplay: true)
                                    */
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
            } else {
                HStack {
                    Spacer()
                    ActivityIndicator(isAnimating: true)
                        .configure { $0.color = .white; $0.style = .large }
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
