//
//  BrowseOnlyMode.swift
//  Concertmaster
//
//  Created by Adriano Brandao on 07/03/20.
//  Copyright © 2020 Open Opus. All rights reserved.
//

import SwiftUI

struct BrowseOnlyMode: View {
    @EnvironmentObject var appState: AppState
    var size: String
    
    var body: some View {
        Button(action: {
            UIApplication.shared.open(URL(string: appState.warningType == .notPremium ? AppConstants.SpotifyPremiumURL : AppConstants.SpotifyAppStoreURL)!)
        }, label: {
            HStack {
                Image("forbidden")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size == "min" ? 16 : 23)
                    .foregroundColor(Color(hex: size == "min" ? 0xFFFFFF : 0x202023))
                    .padding(.trailing, size == "min" ? 0 : 2)
                
                VStack(alignment: .leading) {
                    Text("Preview-only mode")
                        .font(.custom("Sanchez-Regular", size: size == "min" ? 10 : 13))
                        .padding(.top, size == "min" ? 0 : 2)
                    Text("Tap to enable playback")
                        .font(.custom("Sanchez-Regular", size: size == "min" ? 8 : 11))
                        .padding(.top, size == "min" ? -8 : -8)
                }
                .foregroundColor(Color(hex: size == "min" ? 0xFFFFFF : 0x202023))
            }
            .padding(size == "min" ? 0 : 10)
            .padding(.top, size == "min" ? 0 : -2)
            .overlay(RoundedRectangle(cornerRadius: size == "min" ? 0 : 20)
                        .stroke(Color(hex: 0x202023), lineWidth: size == "min" ? 0 : 1))
        })
    }
}

struct BrowseOnlyMode_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
