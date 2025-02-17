//
//  SettingView.swift
//  EasyAccounts
//  设置页
//  Created by 沈俊杰 on 2025/2/2.
//

import SwiftUI

struct SettingView: View {
    @StateObject var accountStore = AccountStore()
    @StateObject var actionStore = ActionStore()
    @StateObject var typeStore = TypeStore()
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("设置")) {
                    NavigationLink(destination: SettingActionView(actionStore: actionStore)) {
                        Label("收支", systemImage: "arrow.left.arrow.right")
                    }
                    NavigationLink(destination: SettingAccountView(accountStore: accountStore)) {
                        Label("账户", systemImage: "creditcard")
                    }
                    NavigationLink(destination: SettingTypeView(typeStore: typeStore)) {
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
    SettingView(accountStore: AccountStore(), actionStore: ActionStore(), typeStore: TypeStore())
}
