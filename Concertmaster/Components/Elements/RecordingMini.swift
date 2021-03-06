//
//  RecordingMini.swift
//  Concertmaster
//
//  Created by Adriano Brandao on 17/02/20.
//  Copyright © 2020 Open Opus. All rights reserved.
//

import SwiftUI
import URLImage

struct RecordingMiniView: View {
    var recording: Recording
    @Binding var currentTrack: [CurrentTrack]
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var previewBridge: PreviewBridge
    @EnvironmentObject var settingStore: SettingStore
    @EnvironmentObject var playState: PlayState
    
    private var appRemote: SPTAppRemote? {
        get {
            return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote
        }
    }
    
    var body: some View {
        HStack {
            if self.currentTrack.count > 0 {
                if !self.appState.noPreviewAvailable {
                    Button(
                        action: {
                            if self.playState.preview {
                                self.previewBridge.togglePlay()
                            } else {
                                if self.currentTrack.first!.playing {
                                    appRemote?.playerAPI?.pause()
                                    if let _ = self.appRemote!.connectionParameters.accessToken {
                                        self.appRemote!.connect()
                                    }
                                } else {
                                    appRemote?.playerAPI?.resume()
                                }
                            }
                    },
                    label: {
                        Image(self.currentTrack.first!.playing ? "pause" : "play")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 22)
                            .foregroundColor(.black)
                            .padding(.leading, 18)
                            .padding(.trailing, 22)
                    })
                    
                    HStack {
                        Text(self.currentTrack.first!.readable_full_position)
                            .foregroundColor(.black)
                        
                        ZStack {
                            ProgressBar(progress: self.currentTrack.first!.full_progress)
                                .padding(.leading, 6)
                                .padding(.trailing, 6)
                                .frame(height: 4)
                            
                            if self.playState.preview {
                                HStack {
                                    BrowseOnlyMode(size: "min")
                                }
                                .padding(.top, 2)
                                .padding(.bottom, 2)
                                .padding(.leading, 8)
                                .padding(.trailing, 12)
                                .background(Color.black)
                                .cornerRadius(5)
                                .opacity(0.7)
                            }
                        }
                        
                        Text(self.recording.readableLength)
                            .foregroundColor(.black)
                    }
                    .font(.custom("Sanchez-Regular", size: 11))

                } else {
                    Spacer()
                    PreviewNotAvailable(size: "min", currentTrack: $currentTrack)
                    Spacer()
                }
            }
        }
        .padding(.top, 4)
    }
}

struct RecordingMini: View {
    var recording: Recording
    @Binding var currentTrack: [CurrentTrack]
    @EnvironmentObject var previewBridge: PreviewBridge
    @EnvironmentObject var settingStore: SettingStore
    @EnvironmentObject var playState: PlayState
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                URLImage(recording.cover ?? URL(fileURLWithPath: AppConstants.concNoCoverImg), placeholder: { _ in
                    Rectangle()
                        .fill(Color(hex: 0x2B2B2F))
                        .frame(width: 50, height: 50)
                        //.cornerRadius(10)
                }) { img in
                    img.image
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                        //.cornerRadius(10)
                }
                .frame(width: 50, height: 50)
                .padding(.trailing, 8)
                
                VStack(alignment: .leading) {
                    if recording.work!.composer!.name != "None" {
                        Text(recording.work!.composer!.name.uppercased())
                            .font(.custom("ZillaSlab-SemiBold", size: 13))
                            .foregroundColor(.black)
                    }
                    
                    Text(recording.work!.title)
                        .font(.custom("PetitaMedium", size: 14))
                        .foregroundColor(.black)
                        .padding(.bottom, 4)
                        .lineLimit(20)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            
            if self.currentTrack.count > 0 {
                if self.currentTrack.first!.loading {
                    HStack {
                        Spacer()
                        ActivityIndicator(isAnimating: true)
                            .configure { $0.color = .black; $0.style = .medium }
                        Spacer()
                    }
                    .padding(.top, 4)
                }
                else {
                    if let playerstate = playState.playerstate {
                        if playerstate.isConnected {
                            RecordingMiniView(recording: self.recording, currentTrack: $currentTrack)
                        } else {
                            HStack {
                                Spacer()
                                SpotifyDisconnected(currentTrack: $currentTrack, size: "min")
                                Spacer()
                            }
                        }
                    } else if self.playState.preview {
                        RecordingMiniView(recording: self.recording, currentTrack: $currentTrack)
                    }
                }
            } else {
                HStack {
                    Button(
                        action: {
                            self.playState.autoplay = true
                            self.playState.recording = self.playState.recording
                    },
                    label: {
                        Image("play")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 22)
                            .foregroundColor(.black)
                            .padding(.leading, 18)
                            .padding(.trailing, 22)
                    })
                    
                    HStack {
                        Text("0:00")
                            .foregroundColor(.black)
                        
                        ZStack {
                            ProgressBar(progress: 0)
                                .padding(.leading, 6)
                                .padding(.trailing, 6)
                                .frame(height: 4)
                        }
                        
                        Text(self.recording.readableLength)
                            .foregroundColor(.black)
                    }
                    .font(.custom("Sanchez-Regular", size: 11))
                }
                .padding(.top, 4)

            }
        }
        .padding(.top, 2)
    }
}

struct RecordingMini_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
