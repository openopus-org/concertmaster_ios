//
//  WorksRadioButton.swift
//  Concertmaster
//
//  Created by Adriano Brandao on 20/03/20.
//  Copyright © 2020 Open Opus. All rights reserved.
//

import SwiftUI

struct WorksRadioButton: View {
    @EnvironmentObject var playState: PlayState
    @EnvironmentObject var settingStore: SettingStore
    @EnvironmentObject var radioState: RadioState
    @EnvironmentObject var mediaBridge: MediaBridge
    @EnvironmentObject var previewBridge: PreviewBridge
    @EnvironmentObject var AppState: AppState
    @State var isLoading = false
    var genreId: String
    
    func initRadio() {
        self.isLoading = true
        var parameters = ["composer": self.genreId.split(separator: "-")[0]]
        
        if self.genreId.split(separator: "-")[1] == "Popular" {
            parameters["popularwork"] = "1"
        } else if self.genreId.split(separator: "-")[1] == "Recommended" {
            parameters["recommendedwork"] = "1"
        } else if self.genreId.split(separator: "-")[1] == "Favorites" {
            parameters["work"] = "fav"
        } else {
            parameters["genre"] = self.genreId.split(separator: "-")[1]
        }
        
        startRadio(userId: self.settingStore.userId, parameters: parameters) { results in
            if let worksData: Works = safeJSON(results) {
              if let wrks = worksData.works {
                    DispatchQueue.main.async {
                        self.radioState.isActive = true
                        self.radioState.playlistId = ""
                        self.radioState.genreId = self.genreId
                        self.radioState.nextRecordings.removeAll()
                        self.radioState.nextWorks = wrks
                        
                        randomRecording(workQueue: self.radioState.nextWorks, hideIncomplete: self.settingStore.hideIncomplete, country: !self.settingStore.country.isEmpty ? self.settingStore.country : "us") { rec in
                            if rec.count > 0 {
                                DispatchQueue.main.async {
                                    self.playState.autoplay = true
                                    self.playState.recording = rec
                                    self.isLoading = false
                                }
                            }
                            else {
                                DispatchQueue.main.async {
                                    alertError("No recordings matching your criteria were found.")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        Button(
            action: {
                if self.radioState.isActive && self.radioState.genreId == self.genreId {
                    self.radioState.isActive = false
                    self.radioState.playlistId = ""
                    self.radioState.genreId = ""
                    self.radioState.nextWorks.removeAll()
                    self.radioState.nextRecordings.removeAll()
                    
                    if self.playState.preview {
                        self.previewBridge.stop()
                        self.previewBridge.setQueueAndPlay(tracks: self.playState.recording.first!.previews!, starttrack: 0, autoplay: false, zeroqueue: false)
                    } else {
                        self.mediaBridge.stop()
                        if let firstrecording = self.playState.recording.first {
                            self.mediaBridge.setQueueAndPlay(tracks: firstrecording.spotify_tracks!, starttrack: firstrecording.spotify_tracks!.first!, autoplay: false)
                        }
                    }
                } else {
                    if self.settingStore.userId != "" {
                        self.initRadio()
                    } else {
                        self.isLoading = true
                        
                        /*
                        userLogin(self.playState.autoplay) { country, canPlay, apmusEligible, loginResults in
                            if let login = loginResults {
                                
                                DispatchQueue.main.async {
                                    self.settingStore.userId = login.user.id
                                    self.settingStore.lastLogged = Int(Date().millisecondsSince1970 / (60 * 1000) | 0)
                                    self.settingStore.country = country
                                    
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
                                    
                                    self.initRadio()
                                }
                            } else {
                                self.isLoading = false
                            }
                        }
                        */
                    }
                }
            },
            label: {
                HStack {
                    HStack {
                        Spacer()
                        
                        if self.isLoading {
                            ActivityIndicator(isAnimating: self.isLoading)
                            .configure { $0.color = .white; $0.style = .medium }
                        } else {
                            AnimatedRadioIcon(color: Color(hex: 0x000000), isAnimated: self.radioState.isActive && self.radioState.genreId == self.genreId)
                                .frame(width: 40, height: 20)
                                .padding(.trailing, self.radioState.isActive && self.radioState.genreId == self.genreId ? 3 : -10)
                                .padding(.leading, self.radioState.isActive && self.radioState.genreId == self.genreId ? 0 : -10)
                                
                            Text((self.radioState.isActive && self.radioState.genreId == self.genreId ? "stop radio" : "start radio").uppercased())
                                .foregroundColor(.black)
                                .font(.custom("ZillaSlab-SemiBold", size: self.radioState.isActive && self.radioState.genreId == self.genreId ? 12 : 14))
                                
                        }
                        
                        Spacer()
                    }
                }
                .padding(13)
                .foregroundColor(.white)
                .background(Color(hex: ((self.radioState.isActive && self.radioState.genreId == self.genreId) || self.isLoading) ? 0x696969 : 0xfce546))
                //.cornerRadius(16)
        })
        .buttonStyle(BorderlessButtonStyle())
        .padding(.bottom, 10)
        .padding(.top, 10)
    }
}

struct WorksRadioButton_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
