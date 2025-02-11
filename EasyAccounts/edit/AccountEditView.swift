//
//  AccountEditView.swift
//  EasyAccounts
//  编辑“账户页”的视图
//  当右划“AccountList”视图，弹出本页面
//  Created by 沈俊杰 on 2025/2/11.
//

import SwiftUI

struct AccountEditView: View {
    @State var account: AccountResponseDto
    
    let completion: (AccountResponseDto) -> Void
    
    @Environment(\.dismiss) private var dismiss   // 关闭sheet弹出页面
    
    var body: some View {
        NavigationStack {
            List(){
                Group{    // 统一给它们添加padding的效果
                    TextField("帐号名称", text: $account.name)
                    TextField("账户余额", text: $account.money)
                    TextField("豁免金额", text: $account.exemptMoney)
                    TextField("银行卡号", text: $account.card)
                    TextField("账户信息备注", text: $account.note)
                }
                .padding(.vertical,8)
            }
            .navigationTitle("编辑账户")
            
            // TODO Done完成按钮
            .safeAreaInset(edge: .bottom) {
                Button(action: {
                    // 完成按钮的具体逻辑
                    // 1.关闭Edit页面；2、将数据往父目录提交
                    dismiss()
                    completion(account)
                }, label: {
                    HStack(spacing: 12){
                        Text("更新")
                            .padding(.vertical,12)
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth:.infinity, alignment:.center)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                })
                .padding(.horizontal,16)
                .padding(.bottom,8)
            }
        }
    }
}

#Preview {
    AccountEditView(
        account: AccountResponseDto(id: 0, name: "测试账户", money: "999", exemptMoney: "0", card: "0000-0000-1234", note: "无"),
        completion: { account in
                print("来自AccountEditView的执行，结果为：\(account.note)")
        }
    )
}
