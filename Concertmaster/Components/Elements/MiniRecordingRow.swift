//
//  RecordingRow.swift
//  Concertmaster
//
//  Created by Adriano Brandao on 14/02/20.
//  Copyright © 2020 Open Opus. All rights reserved.
//

import SwiftUI
import URLImage

struct MiniRecordingRow: View {
    var recording: Recording
    var accentColor: Color
    var textColor: Color
    
    var body: some View {
        HStack(alignment: .top) {
            ZStack(alignment: .bottomTrailing) {
                URLImage(recording.cover ?? URL(fileURLWithPath: AppConstants.concNoCoverImg), placeholder: { _ in
                    Rectangle()
                        .fill(Color(hex: 0x2B2B2F))
                        .frame(width: 70, height: 70)
                        //.cornerRadius(20)
                }) { img in
                    img.image
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                        //.cornerRadius(20)
                }
                .frame(width: 70, height: 70)
                .padding(.trailing, 10)
            }
            VStack(alignment: .leading) {
                if recording.work != nil {
                    if recording.work!.composer!.id != "0" {
                        Text(recording.work!.composer!.name.uppercased().trimmingCharacters(in: .whitespacesAndNewlines))
                            .font(.custom("ZillaSlab-SemiBold", size: 12))
                            .foregroundColor(self.accentColor)
                    } else if recording.work!.composer!.name != "None" {
                        ForEach(recording.work!.composer!.name.components(separatedBy: CharacterSet(charactersIn: "&,")), id: \.self) { composer in
                            Text(composer.uppercased().trimmingCharacters(in: .whitespacesAndNewlines))
                            .font(.custom("ZillaSlab-SemiBold", size: 12))
                            .foregroundColor(self.accentColor)
                        }
                    }
                    
                    Text(recording.work!.title)
                        .font(.custom("PetitaMedium", size: 14))
                        .padding(.bottom, 6)
                        .lineLimit(20)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(self.textColor)
                }
                
                if recording.observation != "" && recording.observation != nil {
                    Text(recording.observation ?? "")
                    .font(.custom("PetitaMedium", size: 9))
                    .padding(.bottom, 6)
                    .foregroundColor(self.textColor)
                }
                
                ForEach(recording.performers, id: \.name) { performer in
                    Group {
                        if (self.recording.performers.count <= AppConstants.maxPerformers || AppConstants.mainPerformersList.contains(performer.role ?? "")) {
                                Text(performer.name)
                                    .font(.custom("PetitaBold", size: (self.recording.work != nil ? 11 : 12)))
                                +
                                Text(performer.readableRole)
                                    .font(.custom("PetitaMedium", size: (self.recording.work != nil ? 11 : 12)))
                        }
                    }
                }
                .foregroundColor(self.textColor)
                .lineLimit(20)
            }
            Spacer()
        }
        .padding(EdgeInsets(top: 20, leading: 4, bottom: 20, trailing: 0))
    }
}

struct MiniRecordingRow_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
