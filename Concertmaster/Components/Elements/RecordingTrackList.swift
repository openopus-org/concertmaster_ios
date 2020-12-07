//
//  RecordingTrackList.swift
//  Concertmaster
//
//  Created by Adriano Brandao on 17/02/20.
//  Copyright © 2020 Open Opus. All rights reserved.
//

import SwiftUI

struct RecordingTrackList: View {
    var recording: Recording
    var color: Color
    
    var body: some View {
        ForEach(self.recording.tracks!, id: \.id) { track in
            Group {
                HStack {
                    Text(track.title)
                        .font(.custom("Barlow-Regular", size: 14))
                        .foregroundColor(color)
                    
                    Spacer()
                    
                    Text(track.readableLength)
                        .font(.custom("ZillaSlab-Light", size: 11))
                        .foregroundColor(color)
                        .padding(.leading, 12)
                }
                
                Divider()
            }
        }
    }
}

struct RecordingTrackList_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
