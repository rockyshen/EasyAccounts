//
//  StaticCard.swift
//  EasyAccounts
//  统计收支的卡片
//  Created by 沈俊杰 on 2025/3/21.
//

import SwiftUI

struct StaticCard: View {
    let title: String
    let value: Int
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.gray)
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text(title).font(.headline)
                Text("\(value)").font(.subheadline)
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}

#Preview {
    StaticCard(title: "每月支出", value: 189, icon: "basket")
}
