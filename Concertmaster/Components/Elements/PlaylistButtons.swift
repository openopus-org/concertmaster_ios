//
//  PlaylistButtons.swift
//  Concertmaster
//
//  Created by Adriano Brandao on 17/03/20.
//  Copyright © 2020 Open Opus. All rights reserved.
//

import SwiftUI

struct PlaylistButtons: View {
    @EnvironmentObject var playState: PlayState
    @EnvironmentObject var settingStore: SettingStore
    @EnvironmentObject var radioState: RadioState
    @EnvironmentObject var previewBridge: PreviewBridge
    @State var isLoading = false
    @State private var showPlaylistSheet = false
    var recordings: [Recording]
    var playlistId: String
    
    private var appRemote: SPTAppRemote? {
        get {
            return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote
        }
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Button(
                action: {
                    if self.radioState.isActive && self.radioState.playlistId == self.playlistId {
                        self.radioState.isActive = false
                        self.radioState.playlistId = ""
                        self.radioState.nextWorks.removeAll()
                        self.radioState.nextRecordings.removeAll()
                        
                        if self.playState.preview {
                            self.previewBridge.stop()
                        } else {
                            appRemote?.playerAPI?.pause()
                            if let _ = self.appRemote!.connectionParameters.accessToken {
                                self.appRemote!.connect()
                            }
                        }
                    } else {
                        var recs = self.recordings
                        recs.shuffle()
                        
                        self.isLoading = true
                        self.radioState.isActive = true
                        self.radioState.playlistId = self.playlistId
                        self.radioState.nextWorks.removeAll()
                        self.radioState.nextRecordings = recs
                        
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
                            } else {
                                AnimatedRadioIcon(color: Color(hex: 0x000000), isAnimated: self.radioState.isActive && self.radioState.playlistId == self.playlistId)
                                    .frame(width: 40, height: 20)
                                    .padding(.trailing, self.radioState.isActive && self.radioState.playlistId == self.playlistId ? -2 : -10)
                                    .padding(.leading, self.radioState.isActive && self.radioState.playlistId == self.playlistId ? 0 : -10)
                                    
                                Text((self.radioState.isActive && self.radioState.playlistId == self.playlistId ? "stop radio" : "start radio").uppercased())
                                    .foregroundColor(.black)
                                    .font(.custom("Sanchez-Regular", size: self.radioState.isActive && self.radioState.playlistId == self.playlistId ? 12 : 13))
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(13)
                    .foregroundColor(.white)
                    .background(Color(hex: self.radioState.isActive && self.radioState.playlistId == self.playlistId ? 0x696969 : 0xfce546))
                    .cornerRadius(5)
            })
            .buttonStyle(BorderlessButtonStyle())
            
            if self.playlistId != "fav" && self.playlistId != "recent" {
                Button(
                    action: { self.showPlaylistSheet = true },
                    label: {
                        HStack {
                            HStack {
                                Spacer()
                                
                                Image("edit")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 12)
                                    .foregroundColor(.white)
                                    .padding(.trailing, 2)
                                
                                Text("edit playlist".uppercased())
                                    .foregroundColor(.white)
                                    .font(.custom("Sanchez-Regular", size: 12))
                                
                                Spacer()
                            }
                        }
                        .padding(15)
                        .foregroundColor(.white)
                        .background(Color(hex: 0x2B2B2F))
                        .cornerRadius(5)
                })
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .padding(.bottom, 10)
        .padding(.top, 10)
        .sheet(isPresented: $showPlaylistSheet) {
            EditPlaylist(playlistId: self.playlistId, playlistName: self.settingStore.playlists.filter({$0.id == self.playlistId}).first!.name, recordings: self.recordings).environmentObject(self.settingStore)
        }
    }
}

struct PlaylistButtons_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
