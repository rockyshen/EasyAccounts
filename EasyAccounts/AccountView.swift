//
//  AccountView.swift
//  EasyAccounts
//
//  Created by 沈俊杰 on 2025/2/10.
//

import SwiftUI

struct AccountView: View {
    var accountResponseDto: AccountResponseDto
    
    var body: some View {
        HStack{
            VStack(alignment: .leading) {
                Text(accountResponseDto.name)
                    .font(.subheadline)
                    .foregroundColor(.black)
                
                Text(accountResponseDto.card)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // 一个圆形的银行logo
            Image(systemName: "creditcard.fill")
                .font(.title3)
                .foregroundColor(.blue) // 设置图标颜色，根据需要调整
                .frame(width: 40, height: 40) // 设置圆形 logo 的大小
                .clipShape(Circle()) // 裁剪为圆形
                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
            
        }
    }
}

#Preview {
    AccountView(accountResponseDto: AccountResponseDto(id: 1, name: "SwiftBank", money: "100", exemptMoney: "0", card: "0000-0000-0000-0000", createTime: nil, note: "备注"))
}
