//
//  EditAccountView.swift
//  EasyAccounts
//  编辑账户页面
//  Created by 沈俊杰 on 2025/2/10.
//

import SwiftUI

struct SettingAccountView: View {
    @StateObject var accountStore = AccountStore()
    
    @State var addNewAccount: AccountResponseDto?
    
    var body: some View {
        NavigationView {
            AccountList(accountStore: accountStore, accounts: accountStore.accountResponseDtoList)
            .padding(15)
            .navigationTitle("账户")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(action: {
                    // 添加账户的操作
                    addNewAccount = AccountResponseDto(id: nil, name: "", money: "", exemptMoney: "", card: "", note: "")
                }) {
                    Text("添加账户")
                }
            }
            // 添加账户
            .sheet(item: $addNewAccount, content: { account in
                AccountEditView(
                    account: account,
                    completion: { newAccount in
//                        print(newAccount)
                         accountStore.addAccount(account: newAccount)
                    }
                )
            })

        }
    }
}

#Preview {
    SettingAccountView()
}
