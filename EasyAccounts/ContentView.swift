//
//  ContentView.swift
//  EasyAccounts
//  主视图 - 支持深色/浅色主题切换
//
//  Created by 沈俊杰 on 2025/2/1.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        TabView(selection: $selectedTab) {
            OverView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("home")
                }
                .tag(0)
            
            DetailView()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("detail")
                }
                .tag(1)
            
            ScreenView()
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("analysis")
                }
                .tag(2)
            
            SettingView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("config")
                }
                .tag(3)
        }
        .tint(.themeAccent)
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        .onAppear {
            updateTabBarAppearance()
        }
        .onChange(of: themeManager.isDarkMode) { _ in
            updateTabBarAppearance()
        }
        .id(themeManager.isDarkMode) // 强制视图在主题切换时刷新
    }
    
    private func updateTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        if themeManager.isDarkMode {
            // 深色主题
            appearance.backgroundColor = UIColor(Color(hex: "000000", opacity: 0.9))
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color(hex: "4A5565"))
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor(Color(hex: "4A5565")),
                .font: UIFont.monospacedSystemFont(ofSize: 10, weight: .medium)
            ]
        } else {
            // 浅色主题
            appearance.backgroundColor = UIColor(Color(hex: "FFFFFF", opacity: 0.95))
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color(hex: "9CA3AF"))
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor(Color(hex: "9CA3AF")),
                .font: UIFont.monospacedSystemFont(ofSize: 10, weight: .medium)
            ]
        }
        
        // 选中状态（两种主题相同）
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.themeAccent)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.themeAccent),
            .font: UIFont.monospacedSystemFont(ofSize: 10, weight: .bold)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView()
}
