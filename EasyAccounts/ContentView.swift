//
//  ContentView.swift
//  EasyAccounts
//
//  Created by 沈俊杰 on 2025/2/1.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        // TODO OverView、DetailView、ScreenView等四个Ta,是不是应该由父级视图ContentView来传递Store，而不是在各自里面new对象
        // SwiftUI提示，Store不能在body中声明！
//        @StateObject var homeStore = HomeStore()
//        @StateObject var detailStore = DetailStore()
//        @StateObject var accountStore = AccountStore()
//        @StateObject var actionStore = ActionStore()
//        @StateObject var typeStore = TypeStore()
        
        TabView {
            OverView()
                .tabItem { Label("总览", systemImage: "house") }
            
            DetailView()
                .tabItem { Label("流水", systemImage: "square.and.pencil") }
            
//            ScreenView()
//                .tabItem { Label("筛选", systemImage: "line.3.horizontal.decrease")}
            
            SettingView()
                .tabItem { Label("设置", systemImage: "gear") }
        }
    }
}

#Preview {
    ContentView()
}
