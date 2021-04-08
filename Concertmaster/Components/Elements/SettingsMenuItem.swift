//
//  SettingsMenuItem.swift
//  Concertmaster
//
//  Created by Adriano Brandao on 01/04/20.
//  Copyright © 2020 Open Opus. All rights reserved.
//

import SwiftUI

struct SettingsMenuItem: View {
    var title: String
    var description: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.custom("ZillaSlab-SemiBold", size: 15))
                .lineLimit(20)
                .foregroundColor(.white)
            
            if description != nil {
                Text(description ?? "")
                    .font(.custom("PetitaMedium", size: 13))
                    .lineLimit(20)
                    .foregroundColor(.white)
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 12)
    }
}

struct SettingsMenuItem_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
