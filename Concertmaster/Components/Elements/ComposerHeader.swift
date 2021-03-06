//
//  ComposerDetail.swift
//  Concertmaster
//
//  Created by Adriano Brandao on 10/02/20.
//  Copyright © 2020 Open Opus. All rights reserved.
//

import SwiftUI
import URLImage

struct ComposerHeader: View {
    var composer: Composer
    @State private var showSheet = false
    @EnvironmentObject var settingStore: SettingStore
    @EnvironmentObject var AppState: AppState
    
    var actionSheet: ActionSheet {
        ActionSheet(title: Text("Select an action"), message: nil, buttons: [
            .default(Text(self.settingStore.favoriteComposers.contains(composer.id) ? "Remove \(composer.name) from favorites" : "Add \(composer.name) to favorites"), action: {
                
                APIpost("\(AppConstants.concBackend)/dyn/user/composer/\(self.settingStore.favoriteComposers.contains(self.composer.id) ? "unfavorite" : "favorite")/", parameters: ["id": self.settingStore.userId, "auth": authGen(userId: self.settingStore.userId, userAuth: self.settingStore.userAuth) ?? "", "cid": self.composer.id]) { results in
                    
                    print(String(decoding: results, as: UTF8.self))
                    
                    DispatchQueue.main.async {
                        if let addComposer: AddComposer = safeJSON(results) {
                            self.settingStore.favoriteComposers = addComposer.list
                            UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController?.showToast(message: "\(self.settingStore.favoriteComposers.contains(self.composer.id) ? "Added!" : "Removed!")", image: "checked", text: nil)
                        }
                    }
                }
            }),
            .default(Text(self.settingStore.forbiddenComposers.contains(composer.id) ? "Remove \(composer.name) from the forbidden list" : "Add \(composer.name) to the forbidden list"), action: {
                
                APIpost("\(AppConstants.concBackend)/dyn/user/composer/\(self.settingStore.favoriteComposers.contains(self.composer.id) ? "permit" : "forbid")/", parameters: ["id": self.settingStore.userId, "auth": authGen(userId: self.settingStore.userId, userAuth: self.settingStore.userAuth) ?? "", "cid": self.composer.id]) { results in
                    
                    print(String(decoding: results, as: UTF8.self))
                    
                    DispatchQueue.main.async {
                        if let addComposer: AddComposer = safeJSON(results) {
                            self.settingStore.forbiddenComposers = addComposer.list
                            UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController?.showToast(message: "\(self.settingStore.forbiddenComposers.contains(self.composer.id) ? "Added!" : "Removed!")", image: "checked", text: nil)
                        }
                    }
                }
            }),
            .cancel()
        ])
    }
    
    var body: some View {
        HStack {
            BackButton()
            
            URLImage(composer.portrait!, placeholder: { _ in
                Rectangle()
                    .fill(Color(hex: 0x2B2B2F))
                    .frame(width: 64, height: 64)
                    .cornerRadius(5)
            }) { img in
                img.image
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            }
            .frame(width: 64, height: 64)
            .cornerRadius(5)
            .padding(.trailing, 4)
            .padding(.leading, 4)
            
            VStack {
                VStack(alignment: .leading) {
                    
                    Text(composer.name.uppercased())
                        .foregroundColor(Color(hex: 0xfce546))
                        .font(.custom("ZillaSlab-SemiBold", size: 18))
                    
                    Group{
                        Text(composer.complete_name)
                        Text("(" + composer.birth!.prefix(4)) + Text(composer.death != nil ? "-" : "") + Text((composer.death?.prefix(4) ?? "")) + Text(")")
                    }
                    .foregroundColor(.white)
                    .lineLimit(20)
                    .font(.custom("Sanchez-Regular", size: 13))
                }
                .padding(5)
            }
            
            Spacer()
            
            if self.settingStore.userId != "" {
                Button(action: {
                    self.showSheet = true
                })
                {
                    EllipsisButton()
                        .actionSheet(isPresented: $showSheet, content: { self.actionSheet })
                }
            }
        }
        .onAppear(perform: { self.endEditing(true) })
    }
}

struct ComposerHeader_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
