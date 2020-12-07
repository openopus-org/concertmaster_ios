//
//  FavoritesButton.swift
//  Concertmaster
//
//  Created by Adriano Brandao on 04/03/20.
//  Copyright © 2020 Open Opus. All rights reserved.
//

import SwiftUI

struct FavoritesButton: View {
    var playlist: String
    var active: Bool
    
    var body: some View {
        VStack {
            Image(playlist == "fav" ? "favorites" : "recent")
                .resizable()
                .foregroundColor(Color(hex: (self.active ? 0x000000 : 0xfce546)))
                .aspectRatio(contentMode: .fill)
                .frame(width: 14, height: 14)
                .padding(.bottom, 1)
                .padding(.top, 6)
            
            Text(playlist == "fav" ? "Your favorites" : "Recently played")
                .foregroundColor(Color(hex: (self.active ? 0x000000 : 0xfce546)))
                .font(.custom("ZillaSlab-Light", size: 12))
                .lineLimit(20)
                .lineSpacing(-4)
        }
        .frame(minWidth: 95, maxWidth: 95, minHeight: 130,  maxHeight: 130)
        .background(Color(hex: (self.active ? 0xfce546 : 0x202023)))
        //.cornerRadius(13)
    }
}

struct FavoritesButton_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
