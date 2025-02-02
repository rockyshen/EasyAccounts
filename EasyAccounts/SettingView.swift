//
//  SettingView.swift
//  EasyAccounts
//
//  Created by 沈俊杰 on 2025/2/2.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("设置")) {
                    NavigationLink(destination: AnyView(Text("收支"))) {
                        Label("收支", systemImage: "arrow.left.arrow.right")
                    }
                    NavigationLink(destination: AnyView(Text("账户"))) {
                        Label("账户", systemImage: "creditcard")
                    }
                    NavigationLink(destination: AnyView(Text("分类"))) {
                        Label("分类", systemImage: "list.dash")
                    }
                    NavigationLink(destination: AnyView(Text("快记模板"))) {
                        Label("快记模板", systemImage: "doc.text")
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SettingView()
}
