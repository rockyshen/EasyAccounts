//
//  EasyAccountsApp.swift
//  EasyAccounts
//
//  Created by 沈俊杰 on 2025/2/1.
//

import SwiftUI

@main
struct EasyAccountsApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                OverView()
                    .tabItem { Label("总览", systemImage: "house") }
                
                FlowView()
                    .tabItem { Label("流水", systemImage: "square.and.pencil") }
                
                ScreenView()
                    .tabItem { Label("筛选", systemImage: "line.3.horizontal.decrease")}
                
                SettingView()
                    .tabItem { Label("设置", systemImage: "gear") }
                
            }
        }
    }
}
