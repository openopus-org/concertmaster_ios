//
//  AlbumPlayButton.swift
//  Concertmaster
//
//  Created by Adriano Brandao on 09/11/20.
//  Copyright © 2020 Open Opus. All rights reserved.
//

import SwiftUI

struct AlbumPlayButtons: View {
    @EnvironmentObject var playState: PlayState
    @EnvironmentObject var settingStore: SettingStore
    @EnvironmentObject var radioState: RadioState
    @EnvironmentObject var previewBridge: PreviewBridge
    @State var isLoading = false
    @State private var showPlaylistSheet = false
    var album: Album
    var recordings: [Recording]
    
    private var appRemote: SPTAppRemote? {
        get {
            return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote
        }
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Button(
                action: {
                    if self.radioState.isActive && self.radioState.playlistId == "album-\(self.album.spotify_albumid)" {
                        self.radioState.isActive = false
                        self.radioState.playlistId = ""
                        self.radioState.nextWorks.removeAll()
                        self.radioState.nextRecordings.removeAll()
                        
                        if self.playState.preview {
                            self.previewBridge.stop()
                            self.previewBridge.setQueueAndPlay(tracks: self.playState.recording.first!.previewUrls, starttrack: 0, autoplay: false, zeroqueue: false)
                        } else {
                            appRemote?.playerAPI?.pause()
                            if let _ = self.appRemote!.connectionParameters.accessToken {
                                self.appRemote!.connect()
                            }
                        }
                    } else {
                        self.isLoading = true
                        self.radioState.isActive = true
                        self.radioState.playlistId = "album-\(self.album.spotify_albumid)"
                        self.radioState.nextWorks.removeAll()
                        self.radioState.nextRecordings = self.recordings
                        
                        let rec = self.radioState.nextRecordings.removeFirst()
                        
                        getRecordingDetail(recording: rec, country: !self.settingStore.country.isEmpty ? self.settingStore.country : "us") { recordingData in
                            DispatchQueue.main.async {
                                self.playState.autoplay = true
                                self.playState.recording = recordingData
                                self.isLoading = false
                            }
                        }
                    }
                },
                label: {
                    HStack {
                        HStack {
                            Spacer()
                            
                            if self.isLoading {
                                ActivityIndicator(isAnimating: self.isLoading)
                                .configure { $0.color = .black; $0.style = .medium }
                            } else if self.radioState.isActive && self.radioState.playlistId == "album-\(self.album.spotify_albumid)" {
                                AnimatedRadioIcon(color: Color(hex: 0x000000), isAnimated: true)
                                    .frame(width: 40, height: 20)
                                    .padding(.trailing, 3)
                                    .padding(.leading, 0)
                                    
                                Text(("stop radio").uppercased())
                                    .foregroundColor(.black)
                                    .font(.custom("Sanchez-Regular", size: self.radioState.isActive && self.radioState.playlistId == "album-\(self.album.spotify_albumid)" ? 11 : 12))
                            } else {
                                Image("play")
                                    .resizable()
                                    .foregroundColor(.black)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 20)
                                Text("play album".uppercased())
                                    .foregroundColor(.black)
                                    .font(.custom("ZillaSlab-SemiBold", size: 15))
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(13)
                    .clipped()
                    .foregroundColor(.white)
                    .background(Color(hex: self.radioState.isActive && self.radioState.playlistId == "album-\(self.album.spotify_albumid)" ? 0x696969 : 0xfce546))
                    .cornerRadius(5)
            })
            
            Button(
                action: { UIApplication.shared.open(URL(string: AppConstants.spotifyLink.replacingOccurrences(of: "%%COUNTRY%%", with: self.settingStore.country.isEmpty ? "us" : self.settingStore.country) + album.spotify_albumid)!) },
                label: {
                    HStack {
                        Spacer()
                        Image("listen-on-spotify")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 22)
                        Spacer()
                    }
                    .padding(13)
                    .clipped()
                    .background(Color(hex: 0x2B2B2F))
                    .cornerRadius(5)
            })
        }
    }
}

struct AlbumPlayButtons_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
