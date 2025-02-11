//
//  AccountList.swift
//  EasyAccounts
//
//  Created by 沈俊杰 on 2025/2/10.
//

import SwiftUI

struct AccountList: View {
    var accounts: [AccountResponseDto]
    
    @State var editingAccount: AccountResponseDto?
    
    @StateObject var accountStore = AccountStore()
    
    var body: some View {
        List {
            ForEach(accounts) {account in
                AccountView(accountResponseDto: account)
                    .swipeActions(edge: .trailing){
                        Button("删除",role: .destructive){
                            // 实现删除这一条Flow的逻辑
                        }
                    }
                    .swipeActions(edge: .leading){
                        Button("编辑"){
                            // 实现编辑修改这一条Flow的逻辑
                            editingAccount = account
                        }.tint(.blue)
                    }
            }
        }
        .listStyle(PlainListStyle())
        .sheet(item: $editingAccount, content: {account in
            AccountEditView(
                account: account,
                completion: { newAccount in
                    accountStore.updateAccount(account: newAccount)
                }
            )
        })
    }
}

#Preview {
    AccountList(accounts: [
        AccountResponseDto(id: 1, name: "SwiftBank", money: "100", exemptMoney: "0", card: "0000-0000-0000-0000", createTime: nil, note: "备注"),
        AccountResponseDto(id: 2, name: "TestBank", money: "88", exemptMoney: "0", card: "0000-0000-0000-1234", createTime: nil, note: "备注"),
        
    ])
}
