//
//  Settings.swift
//  Concertmaster
//
//  Created by Adriano Brandao on 29/01/20.
//  Copyright © 2020 Open Opus. All rights reserved.
//

import SwiftUI
import SwiftyStoreKit
import UIKit
import AuthenticationServices
import StoreKit

struct Settings: View {
    @Environment(\.window) var window: UIWindow?
    @EnvironmentObject var settingStore: SettingStore
    @State private var supporters = [String]()
    @State private var donationIsLoading = true
    @State private var donationDone = false
    @State private var inAppOffers = [SKProduct]()
    
    func loadData() {
        APIget(AppConstants.openOpusBackend+"/patron/list.json") { results in
            if var supportersData: Supporters = safeJSON(results) {
                DispatchQueue.main.async {
                    supportersData.patrons.shuffle()
                    self.supporters = supportersData.patrons
                }
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                Section(header:
                    VStack(alignment: .leading) {
                        Text("Library filters".uppercased())
                            .font(.custom("ZillaSlab-SemiBold", size: 14))
                            .foregroundColor(Color(hex: 0xfce546))
                        if #available(iOS 14.0, *) {
                            Text("Automatic filters that try to eliminate bad or undesirable recordings from the library. They are not perfect, but definitely can improve your playing experience.")
                                .textCase(.none)
                                .font(.custom("PetitaMedium", size: 14))
                                .foregroundColor(.white)
                                .lineLimit(20)
                        } else {
                            Text("Automatic filters that try to eliminate bad or undesirable recordings from the library. They are not perfect, but definitely can improve your playing experience.")
                                .font(.custom("PetitaMedium", size: 14))
                                .foregroundColor(.white)
                                .lineLimit(20)
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                    ){
                        Toggle(isOn: self.$settingStore.hideIncomplete) {
                            Text("Hide incomplete recordings")
                            .font(.custom("PetitaMedium", size: 16))
                        }
                        .listRowBackground(Color.black)
                    
                        Toggle(isOn: self.$settingStore.hideHistorical) {
                            Text("Hide old, historical recordings")
                            .font(.custom("PetitaMedium", size: 16))
                        }
                        .listRowBackground(Color.black)
                }
                
                Section(header:
                    VStack(alignment: .leading) {
                        Text("Support us!".uppercased())
                            .font(.custom("ZillaSlab-SemiBold", size: 14))
                            .foregroundColor(Color(hex: 0xfce546))
                        if #available(iOS 14.0, *) {
                            Text("Help us keep Concertmaster free! Donate and back our development and hosting costs. Choose a tip value below. You will be charged only once and the transaction will be processed through Apple.")
                                .textCase(.none)
                                .font(.custom("PetitaMedium", size: 14))
                                .foregroundColor(.white)
                                .lineLimit(20)
                        } else {
                            Text("Help us keep Concertmaster free! Donate and back our development and hosting costs. Choose a tip value below. You will be charged only once and the transaction will be processed through Apple.")
                                .font(.custom("PetitaMedium", size: 14))
                                .foregroundColor(.white)
                                .lineLimit(20)
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                ) {
                    HStack {
                        Spacer()
                        
                        if donationIsLoading {
                            ActivityIndicator(isAnimating: donationIsLoading)
                                .configure { $0.color = .white; $0.style = .medium }
                        } else if donationDone {
                            Image("favorites")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color(hex: 0xfce546))
                                .frame(height: 18)
                                .padding(.trailing, 1)
                            
                            Text("Thank you so much for your donation!")
                                .font(.custom("PetitaMedium", size: 15))
                        } else {
                            HStack {
                                ForEach (self.inAppOffers.sorted { $0.price.decimalValue < $1.price.decimalValue }, id: \.self) { product in
                                    Button(
                                        action: {
                                            self.donationIsLoading = true
                                            SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
                                                self.donationIsLoading = false
                                                switch result {
                                                    case .success(let purchase):
                                                        self.donationDone = true
                                                        self.settingStore.lastAskedDonation = Int(Date().millisecondsSince1970 / (60 * 1000) | 0)
                                                        self.settingStore.hasDonated = true
                                                        print("Purchase Success: \(purchase.productId)")
                                                    case .error(let error):
                                                        switch error.code {
                                                            case .unknown: print("Unknown error. Please contact support")
                                                            case .clientInvalid: print("Not allowed to make the payment")
                                                            case .paymentCancelled: break
                                                            case .paymentInvalid: print("The purchase identifier was invalid")
                                                            case .paymentNotAllowed: print("The device is not allowed to make the payment")
                                                            case .storeProductNotAvailable: print("The product is not available in the current storefront")
                                                            case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                                                            case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                                                            case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                                                            default: print((error as NSError).localizedDescription)
                                                        }
                                                }
                                            }
                                        },
                                        label: {
                                            Text("\(product.localizedPrice!)")
                                                .foregroundColor(.black)
                                                .font(.custom("PetitaBold", size: 15))
                                                .padding(10)
                                                .background(Color(hex: 0xfce546))
                                                .cornerRadius(5)
                                        })
                                        .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .listRowBackground(Color.black)
                }
                
                Section(header:
                    VStack(alignment: .leading) {
                        Text("Become our patron".uppercased())
                            .font(.custom("ZillaSlab-SemiBold", size: 14))
                            .foregroundColor(Color(hex: 0xfce546))
                            
                        if #available(iOS 14.0, *) {
                            Text("One-time tips are great, recurrent donations are amazing! Patrons receive early updates and get their names listed here.")
                                .textCase(.none)
                                .font(.custom("PetitaMedium", size: 14))
                                .foregroundColor(.white)
                                .lineLimit(20)
                        } else {
                            Text("One-time tips are great, recurrent donations are amazing! Patrons receive early updates and get their names listed here.")
                                .font(.custom("PetitaMedium", size: 14))
                                .foregroundColor(.white)
                                .lineLimit(20)
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                        
                    ){
                        ForEach(supporters, id: \.self) { supporter in
                            Text(supporter)
                                .font(.custom("Sanchez-Regular", size: 12))
                                .foregroundColor(.white)
                                .lineLimit(20)
                        }
                        .listRowBackground(Color.black)
                    
                        Button(
                            action: { UIApplication.shared.open(URL(string: "https://patreon.com/openopus")!) },
                            label: {
                                SettingsMenuItem(title: "Become a patron!")
                        })
                        .listRowBackground(Color.black)
                }
                
                Section(header:
                    Text("About".uppercased())
                        .font(.custom("ZillaSlab-SemiBold", size: 14))
                        .foregroundColor(Color(hex: 0xfce546))
                    ){
                        SettingsMenuItem(title: "Version", description: AppConstants.version)
                            .listRowBackground(Color.black)
                        
                        Button(
                            action: { UIApplication.shared.open(URL(string: "https://github.com/openopus-org/concertmaster_ios")!) },
                            label: {
                                SettingsMenuItem(title: "Contribute with code", description: "Concertmaster is an open source project. You may fork it or help us with code!")
                        })
                            .listRowBackground(Color.black)
                    
                        Button(
                            action: { UIApplication.shared.open(URL(string: "https://twitter.com/_concertmaster")!) },
                            label: {
                                SettingsMenuItem(title: "Find us on Twitter", description: "And tell us how has been your experience with Concertmaster so far!")
                        })
                            .listRowBackground(Color.black)
                }
            }
            .listStyle(GroupedListStyle())
        }
        .onAppear(perform: {
            if self.supporters.count == 0 {
                print("🆗 supporters loaded from appearance")
                self.loadData()
            }
            
            SwiftyStoreKit.retrieveProductsInfo(Set(AppConstants.inAppPurchases)) { result in
                if result.retrievedProducts.first != nil {
                    for prod in result.retrievedProducts {
                        self.inAppOffers.append(prod)
                    }
                    self.donationIsLoading = false
                }
            }
        })
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
