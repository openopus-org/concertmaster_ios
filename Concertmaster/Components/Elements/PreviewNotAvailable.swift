//
//  PreviewNotAvailable.swift
//  Concertmaster
//
//  Created by Adriano Brandao on 27/03/21.
//  Copyright © 2021 Open Opus. All rights reserved.
//

import SwiftUI

struct PreviewNotAvailable: View {
    var size: String
    @Binding var currentTrack: [CurrentTrack]
    @EnvironmentObject var previewBridge: PreviewBridge
    @EnvironmentObject var settingStore: SettingStore
    @EnvironmentObject var radioState: RadioState
    @EnvironmentObject var playState: PlayState
    
    var body: some View {
        Group {
            if size == "min" {
                HStack(alignment: .center) {
                    PreviewNotAvailable_Icon(size: self.size)
                    PreviewNotAvailable_Message(size: self.size)
                }
            } else if size == "max" {
                if self.radioState.nextRecordings.count > 0 {
                    HStack(alignment: .top) {
                        Spacer()
                        
                        VStack(alignment: .center) {
                            PreviewNotAvailable_Icon(size: "medium")
                            PreviewNotAvailable_Message(size: "medium")
                        }
                        
                        Button(
                            action: {
                                self.previewBridge.stop()
                                self.playState.autoplay = true
                                self.currentTrack[0].track_position = 0
                                self.playState.recording = [self.radioState.nextRecordings.removeFirst()]
                            },
                            label: {
                                Image("skipradio")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 18)
                                .foregroundColor(Color(hex: 0x000000))
                                .padding(.leading, 22)
                                .padding(.top, 10)
                            })
                        
                        Spacer()
                    }
                } else {
                    VStack(alignment: .center) {
                        PreviewNotAvailable_Icon(size: self.size)
                        PreviewNotAvailable_Message(size: self.size)
                    }
                }
            }
        }
        .padding(.top, size == "min" ? 8 : 16)
        .padding(.bottom, size == "min" ? 0 : 32)
    }
}

struct PreviewNotAvailable_Icon: View {
    var size: String
    
    var body: some View {
        Image("browseonly")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size == "min" ? 18 : size == "max" ? 48 : 32)
            .foregroundColor(Color(hex: 0x202023))
            .padding(.trailing, size == "min" ? 0 : 2)
    }
}

struct PreviewNotAvailable_Message: View {
    var size: String
    
    var body: some View {
        Text("This album has no previews")
            .foregroundColor(Color(hex: 0x202023))
            .font(.custom("Sanchez-Regular", size: size == "min" ? 11 : size == "max" ? 13 : 8))
            .padding(.top, size == "min" ? 0 : 2)
    }
}

struct PreviewNotAvailable_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
