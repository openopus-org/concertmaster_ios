//
//  SpotifyDisconnected.swift
//  Concertmaster
//
//  Created by Adriano Brandao on 04/03/21.
//  Copyright © 2021 Open Opus. All rights reserved.
//

import SwiftUI
import StoreKit

struct SpotifyDisconnected: View {
    @Binding var currentTrack: [CurrentTrack]
    var size: String
    @EnvironmentObject var playState: PlayState
    
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
    
    var body: some View {
        Button(action: {
            self.currentTrack[0].loading = true
            self.playState.forceConnection = true
            if let _ = self.appRemote!.connectionParameters.accessToken {
                self.appRemote!.connect()
            } else {
                self.playState.logAndPlay = false
                self.sessionManager?.initiateSession(with: AppConstants.SpotifyAuthScopes, options: .default)
            }
        }, label: {
            HStack {
                Image("forbidden")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size == "min" ? 16 : 23)
                    .foregroundColor(Color(.black))
                    .padding(.trailing, size == "min" ? 0 : 2)
                
                VStack(alignment: .leading) {
                    Text("Spotify out of sync")
                        .font(.custom("ZillaSlab-SemiBold", size: size == "min" ? 10 : 15))
                        .padding(.top, size == "min" ? 0 : 2)
                    Text("Tap to re-connect")
                        .font(.custom("Sanchez-Regular", size: size == "min" ? 8 : 11))
                        .padding(.top, size == "min" ? -8 : -8)
                }
                .foregroundColor(Color(.black))
            }
        })
    }
}

struct SpotifyDisconnected_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
