//
//  EditActionView.swift
//  EasyAccounts
//
//  Created by 沈俊杰 on 2025/2/10.
//

import SwiftUI

struct SettingActionView: View {
    @StateObject var actionStore = ActionStore()
    
    var body: some View {
        NavigationView {
            VStack {
                ForEach(actionStore.actions, id: \.id) { action in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(action.hName)
                                .font(.headline)
                            
                            Text("账户金额增加")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(5)
                                .background((action.hName == "收入" || action.hName == "借入" || action.hName == "收钱") ? Color.green : ((action.hName == "支出" || action.hName == "还钱" || action.hName == "借出") ? Color.red : Color.blue))
                                .cornerRadius(5)
                        }
                        
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                        // TODO 暂不开放修改Action的功能，用默认就够用了！
                    }
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(.bottom, 15)
                }
            }
            .padding(15)
            .navigationTitle("收支")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(action: {
                    // 添加账户的操作
                }) {
                    // 标灰，暂不开放修改收支分类的功能，默认的就够用了！
                    Text("添加收支")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

#Preview {
    SettingActionView()
}
