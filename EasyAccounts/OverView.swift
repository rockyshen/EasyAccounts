//
//  overview.swift
//  EasyAccounts
//  总览页
//  Created by 沈俊杰 on 2025/2/2.
//

import SwiftUI

struct OverView: View {
    @StateObject var homeStore = HomeStore()
    
    var body: some View {
        VStack(alignment: .leading) {
            // Header
            HStack {
                Text("总览")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                Spacer()
                HStack {
                    Button(action: {
                        // Add functionality for menu button
                    }) {
                        Text("财务分析")
                            .font(.subheadline)
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
                Text("¥\(homeStore.homeDto.totalAsset)")
                    .font(.largeTitle)
                    .foregroundColor(.black)
            }
            .padding()
            
            // Income and expenditure
            VStack(alignment: .leading) {
                HStack {
                    Text("当年收支情况").foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 10) // 设置左右边距
                .overlay(
                    HStack {
                        Rectangle().frame(width: 100, height: 1).foregroundColor(.blue) // 左侧横线
                        Spacer()
                        Rectangle().frame(width: 100, height: 1).foregroundColor(.blue) // 右侧横线
                    }
                )
                .padding(.vertical, 10) // 设置上下边距
            
                VStack(alignment: .leading) {
                    HStack {
                        Text("本年总收入：")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        Text("¥\(homeStore.homeDto.yearIncome)")
                            .font(.headline)
                            .foregroundColor(.green)
                    }

                    HStack {
                        Text("本年总支出：")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        Text("¥\(homeStore.homeDto.yearOutCome)")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                    
                    HStack {
                        Text("本年结余：")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        Text("¥\(homeStore.homeDto.yearBalance)")
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                }
            }
            .padding()
            
            // Account assets
            VStack(alignment: .leading) {
                HStack {
                    Text("账户资产").foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 10) // 设置左右边距
                .overlay(
                    HStack {
                        Rectangle().frame(width: 100, height: 1).foregroundColor(.blue) // 左侧横线
                        Spacer()
                        Rectangle().frame(width: 100, height: 1).foregroundColor(.blue) // 右侧横线
                    }
                )
                .padding(.vertical, 5) // 设置上下边距
                
                // TODO 设置页-账户 如果更新了，这里应该同步刷新！
                List {
                    ForEach(homeStore.homeDto.accounts, id: \.id) { account in
                        HStack {
                            Text(account.accountName)
                                .font(.subheadline)
                                .foregroundColor(.black)
                            Spacer()
                            Text("¥\(account.accountAsset)")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                    }
                }.listStyle(PlainListStyle())
            }
            .padding()
            
            Spacer()

        }
    }
}


#Preview {
    OverView(homeStore: HomeStore())   // 这里构造HomeStore太复杂了，就不在这里预览了！
}
