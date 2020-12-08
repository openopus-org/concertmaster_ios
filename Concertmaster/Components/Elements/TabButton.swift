//
//  TabButton.swift
//  Concertmaster
//
//  Created by Adriano Brandao on 29/01/20.
//  Copyright © 2020 Open Opus. All rights reserved.
//

import SwiftUI

struct TabButton: View {
    @EnvironmentObject var AppState: AppState
    @EnvironmentObject var radioState: RadioState
    var icon: String
    var label: String
    var tab: String
    
    var body: some View {
        Button(
            action: { self.AppState.fullPlayer = false; self.AppState.currentTab = self.tab },
            label: {
                VStack {
                    Spacer()
                    
                    if tab == "radio" {
                        AnimatedRadioIcon(color: Color(hex: self.AppState.currentTab == self.tab ? 0xfce546 : (self.radioState.isActive ? 0x000000 : 0x7C726E)), isAnimated: self.radioState.isActive)
                            .frame(width: 60, height: 32)
                            .padding(.top, -4)
                            .padding(.bottom, 7)
                    } else {
                        Image(icon)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color(hex: self.AppState.currentTab == self.tab ? 0xfce546 : 0x7C726E))
                            .frame(width: UIDevice.current.isLarge ? 60 : 40, height: UIDevice.current.isLarge ? 20 : 16)
                    }
                    
                    Text(label)
                        
                        .font(.custom("Sanchez-Regular", size: 9))
                        .foregroundColor(Color(hex: self.AppState.currentTab == self.tab ? 0xfce546 : (self.radioState.isActive && tab == "radio" ? 0xFFFFFF : 0x7C726E)))
                        .padding(.top, icon == "radio" ? -14 : 0)
                }
            })
            .frame(height: 40)
    }
}

struct TabButton_Previews: PreviewProvider {
    static var previews: some View {
        TabButton(icon: "radio", label: "Radio", tab: "radio")
    }
}
