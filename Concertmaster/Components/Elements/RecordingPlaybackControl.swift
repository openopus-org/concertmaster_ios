//
//  RecordingPlaybackControl.swift
//  Concertmaster
//
//  Created by Adriano Brandao on 24/02/20.
//  Copyright © 2020 Open Opus. All rights reserved.
//

import SwiftUI

struct RecordingPlaybackControl: View {
    @Binding var currentTrack: [CurrentTrack]
    @EnvironmentObject var mediaBridge: MediaBridge
    @EnvironmentObject var previewBridge: PreviewBridge
    @EnvironmentObject var settingStore: SettingStore
    @EnvironmentObject var radioState: RadioState
    @EnvironmentObject var playState: PlayState
    
    private var appRemote: SPTAppRemote? {
        get {
            return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote
        }
    }
    
    var body: some View {
        Group {
            if self.currentTrack.count > 0 {
                if self.currentTrack.first!.loading {
                    HStack {
                        Spacer()
                        ActivityIndicator(isAnimating: true)
                            .configure { $0.color = .black; $0.style = .large }
                        Spacer()
                    }
                }
                else {
                    HStack {
                        Spacer()
                        
                        AirPlayButton()
                            .frame(width: 50)
                            .frame(height: 50)
                            .padding(.leading, -8)
                            .padding(.trailing, 10)
                        
                        Button(
                            action: {
                                if self.currentTrack.first!.preview {
                                    if self.currentTrack.first!.track_index == 0 {
                                        self.previewBridge.skipToBeginning()
                                    } else {
                                        self.previewBridge.previousTrack()
                                    }
                                } else {
                                    appRemote?.playerAPI?.skip(toPrevious: {_, error in
                                        if let error = error {
                                            dump(error as NSError)
                                        }
                                    })
                                }
                            },
                            label: {
                                Image("skiptrack")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 24)
                                    .foregroundColor(.black)
                                .rotationEffect(.degrees(180))
                            })
                        
                        Button(
                            action: {
                                if self.currentTrack.first!.preview {
                                    self.previewBridge.togglePlay()
                                } else {
                                    if self.currentTrack.first!.playing {
                                        appRemote?.playerAPI?.pause()
                                    } else {
                                        appRemote?.playerAPI?.resume()
                                    }
                                }
                            },
                            label: {
                                Image(self.currentTrack.first!.playing ? "pause" : "play")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 58)
                                    .foregroundColor(.black)
                                .padding(.leading, 32)
                                .padding(.trailing, 32)
                            })
                        
                        Button(
                            action: {
                                if self.currentTrack.first!.preview {
                                    self.previewBridge.nextTrack()
                                } else {
                                    appRemote?.playerAPI?.skip(toNext: {_, error in
                                        if let error = error {
                                            dump(error as NSError)
                                        }
                                    })
                                }
                            },
                            label: {
                                Image("skiptrack")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 24)
                                    .foregroundColor(.black)
                            })
                        
                        Button(
                            action: {
                                if self.radioState.isActive && self.radioState.canSkip  {
                                    if self.radioState.nextRecordings.count > 0 {
                                        
                                        if self.currentTrack.first!.preview {
                                            self.previewBridge.stop()
                                        } else {
                                            self.mediaBridge.stop()
                                        }
                                        
                                        self.playState.autoplay = true
                                        self.currentTrack[0].track_position = 0
                                        self.playState.recording = [self.radioState.nextRecordings.removeFirst()]
                                    } else if self.radioState.isActive {
                                        self.radioState.isActive = false
                                    }
                                }
                            },
                            label: {
                                Image("skipradio")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 18)
                                .foregroundColor(Color(hex: self.radioState.isActive && self.radioState.canSkip ? 0x000000 : 0xFCE546))
                                .padding(.leading, 22)
                            })

                        
                        Spacer()
                    }
                }
            }
            else {
                HStack {
                    Spacer()
                    
                    Button(
                        action: {
                            self.playState.autoplay = true
                            self.playState.recording = self.playState.recording
                        },
                        label: {
                            Image("play")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 58)
                                .foregroundColor(.black)
                                .padding(.leading, 32)
                                .padding(.trailing, 32)
                        })
                    
                    Spacer()
                }
                
                /*
                if self.settingStore.userId > 0 || self.settingStore.firstUsage {
                    //RecordingNotAvailable(size: "max")
                    
                }
                else {
                    BrowseOnlyMode(size: "max")
                }
                */
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 32)
    }
}

struct RecordingPlaybackControl_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
