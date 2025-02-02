//
//  overview.swift
//  EasyAccounts
//  总览页
//  Created by 沈俊杰 on 2025/2/2.
//

import SwiftUI

struct OverView: View {
    var body: some View {
        VStack(alignment: .leading) {
            // Header
            HStack {
                Text("总览")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                HStack {
                    Button(action: {
                        // Add functionality for menu button
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.blue)
            
            // Total assets
            VStack(alignment: .leading) {
                Text("总资产")
                    .font(.footnote)
                    .foregroundColor(.gray)
                Text("¥390.00")
                    .font(.largeTitle)
                    .foregroundColor(.black)
            }
            .padding()
            
            // Income and expenditure
            VStack(alignment: .leading) {
                Text("当年收支情况")
                    .font(.footnote)
                    .foregroundColor(.gray)
                HStack {
                    VStack(alignment: .leading) {
                        Text("本年总收入")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        Text("¥300.00")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("本年总支出")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        Text("¥33.00")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                }
                .padding()
                Text("本年结余：¥267.00")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
            .padding()
            
            // Account assets
            VStack(alignment: .leading) {
                Text("账户资产")
                    .font(.footnote)
                    .foregroundColor(.gray)
                HStack {
                    Image(systemName: "appstore")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    VStack(alignment: .leading) {
                        Text("支付宝")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        Text("余额：¥300.00")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
            }
            .padding()
        }
    }
}

#Preview {
    OverView()
}
