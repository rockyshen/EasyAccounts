//
//  EditAccountView.swift
//  EasyAccounts
//  编辑账户页面
//  Created by 沈俊杰 on 2025/2/10.
//

import SwiftUI

struct EditAccountView: View {
    @StateObject var accountStore = AccountStore()
    
    var body: some View {
        NavigationView {
            AccountList(accounts: accountStore.accountResponseDtoList)
            .padding(15)
            .navigationTitle("账户")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(action: {
                    // 添加账户的操作
                }) {
                    Text("添加账户")
                }
            }

        }
    }
}

#Preview {
    EditAccountView()
}
