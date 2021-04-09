//
//  Warning.swift
//  Concertmaster
//
//  Created by Adriano Brandao on 23/05/20.
//  Copyright © 2020 Open Opus. All rights reserved.
//

import SwiftUI
import StoreKit

struct Warning: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var playState: PlayState
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                Text("warning".uppercased())
                    .foregroundColor(Color(hex: 0x717171))
                    .font(.custom("Sanchez-Regular", size: 12))
                    .multilineTextAlignment(.leading)
                
                Text(appState.warningType == .notPremium ? "Concertmaster needs a Spotify Premium subscription to play music" : "Concertmaster needs the Spotify app installed on your device")
                    .foregroundColor(Color.white)
                    .font(.custom("PetitaBold", size: 17))
                    .padding(.top, 22)
                    .multilineTextAlignment(.center)
                
                Text("You can browse Concertmaster's catalogue, create playlists, favorite works, composers and recordings, but playback is restricted to 30-second samples.")
                    .foregroundColor(Color.white)
                    .font(.custom("PetitaMedium", size: 14))
                    .padding(.top, 10)
                    .padding(.bottom, 18)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 12) {
                    
                    Button(
                        action: {
                            UIApplication.shared.open(URL(string: appState.warningType == .notPremium ? AppConstants.SpotifyPremiumURL : AppConstants.SpotifyAppStoreURL)!)
                        },
                        label: {
                            HStack {
                                HStack {
                                    Spacer()
                                    Text(appState.warningType == .notPremium ? "Go Premium".uppercased() : "Install".uppercased())
                                        .font(.custom("ZillaSlab-SemiBold", size: 13))
                                    Spacer()
                                }
                            }
                            .padding(12)
                            .foregroundColor(.black)
                            .background(Color(hex: 0xfce546))
                            .cornerRadius(5)
                    })
                    
                    Button(
                        action: {
                            self.appState.showingWarning = false
                        },
                        label: {
                            HStack {
                                HStack {
                                    Spacer()
                                    Text("close".uppercased())
                                        .font(.custom("Sanchez-Regular", size: 11))
                                    Spacer()
                                }
                            }
                            .padding(12)
                            .foregroundColor(.white)
                            .background(Color(hex: 0x555555))
                            .cornerRadius(5)
                    })
                }
                .padding(.top, 20)
            }
            .padding(25)
            .background(Color(hex: 0x2b2b2f))
            .cornerRadius(5)
            .frame(maxWidth: 320)
            
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color.black.opacity(0.8))
        .edgesIgnoringSafeArea(UIDevice.current.isLarge ? .all : .bottom)
    }
}

struct Warning_Previews: PreviewProvider {
    static var previews: some View {
        Warning()
    }
}
