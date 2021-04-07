//
//  RecordingPlaybackControl.swift
//  Concertmaster
//
//  Created by Adriano Brandao on 24/02/20.
//  Copyright © 2020 Open Opus. All rights reserved.
//

import SwiftUI

struct RecordingPlaybackControlButtons: View {
    @Binding var currentTrack: [CurrentTrack]
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
        HStack {
            Spacer()
            
            AirPlayButton()
                .frame(width: 50)
                .frame(height: 50)
                .padding(.leading, -8)
                .padding(.trailing, 10)
            
            Button(
                action: {
                    if self.playState.preview {
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
                    Image(self.currentTrack.first?.playing ?? false ? "pause" : "play")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 58)
                        .foregroundColor(.black)
                    .padding(.leading, 32)
                    .padding(.trailing, 32)
                })
            
            Button(
                action: {
                    if self.radioState.isActive && self.radioState.canSkip && self.currentTrack.first!.track_index == self.playState.recording.first!.tracks!.count - 1 {
                        if self.radioState.nextRecordings.count > 0 {
                            if self.playState.preview {
                                self.previewBridge.stop()
                            } else {
                                appRemote?.playerAPI?.pause()
                            }
                            
                            self.playState.autoplay = true
                            self.currentTrack[0].track_position = 0
                            self.playState.recording = [self.radioState.nextRecordings.removeFirst()]
                        } else if self.radioState.isActive {
                            self.radioState.isActive = false
                            if self.playState.preview {
                                self.previewBridge.nextTrack()
                            } else {
                                appRemote?.playerAPI?.skip(toNext: {_, error in
                                    if let error = error {
                                        dump(error as NSError)
                                    }
                                })
                            }
                        }
                    } else {
                        if self.playState.preview {
                            self.previewBridge.nextTrack()
                        } else {
                            appRemote?.playerAPI?.skip(toNext: {_, error in
                                if let error = error {
                                    dump(error as NSError)
                                }
                            })
                        }
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
                            if self.playState.preview {
                                self.previewBridge.stop()
                            } else {
                                appRemote?.playerAPI?.pause()
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

struct RecordingPlaybackControl: View {
    @Binding var currentTrack: [CurrentTrack]
    @EnvironmentObject var previewBridge: PreviewBridge
    @EnvironmentObject var settingStore: SettingStore
    @EnvironmentObject var radioState: RadioState
    @EnvironmentObject var playState: PlayState
    
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
                    if let playerstate = playState.playerstate {
                        if playerstate.isConnected {
                            RecordingPlaybackControlButtons(currentTrack: $currentTrack)
                        } else {
                            HStack {
                                Spacer()
                                
                                SpotifyDisconnected(currentTrack: $currentTrack, size: "max")
                                
                                Spacer()
                            }
                        }
                    } else if self.playState.preview {
                        RecordingPlaybackControlButtons(currentTrack: $currentTrack)
                    }
                }
            } else {
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
