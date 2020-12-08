//
//  Radio.swift
//  Concertmaster
//
//  Created by Adriano Brandao on 29/01/20.
//  Copyright © 2020 Open Opus. All rights reserved.
//

import SwiftUI

struct Radio: View {
    @State private var showSheet = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                Text("Build your radio station".uppercased())
                    .font(.custom("ZillaSlab-SemiBold", size: 13))
                    .foregroundColor(Color(hex: 0xfce546))
                Text("Build your no-nonsense classical radio! Start a continuous stream of music based on what you want to hear.")
                    .font(.custom("PetitaMedium", size: 14))
                
                RadioBuilder()
                    .padding(.trailing, -20)
                
                Text("Preset radios".uppercased())
                    .font(.custom("ZillaSlab-SemiBold", size: 13))
                    .foregroundColor(Color(hex: 0xfce546))
                    .padding(.top, 20)
                Text("Try one of our carefully curated radio stations. Good for any mood!")
                    .font(.custom("PetitaMedium", size: 14))
                
                RadioStationsGrid()
                    .padding(.top, 12)
                    .padding(.bottom, 20)
            }
            .padding(20)
        }
    }
}

struct Radio_Previews: PreviewProvider {
    static var previews: some View {
        Radio()
    }
}
