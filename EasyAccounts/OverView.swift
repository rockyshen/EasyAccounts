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
                Spacer()
                HStack {
                    Button(action: {
                        // Add functionality for menu button
                    }) {
                        Text("财务分析")
                            .font(.subheadline)
                            
                    }
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            
            // Total assets
            VStack(alignment: .leading) {
                Text("总资产")
                    .font(.footnote)
                    .foregroundColor(Color.greyDarkMode)
                Text("¥\(homeStore.homeDto.totalAsset)")
                    .font(.largeTitle)
                    .foregroundColor(Color.blackDarkMode)
            }
            .padding()

            
            // Income and expenditure
            VStack(alignment: .leading) {
                HStack {
                    Text("当年收支情况").foregroundColor(.accentColor)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 10) // 设置左右边距
                .overlay(
                    HStack {
                        Rectangle().frame(width: 100, height: 1).foregroundColor(.accentColor) // 左侧横线
                        Spacer()
                        Rectangle().frame(width: 100, height: 1).foregroundColor(.accentColor) // 右侧横线
                    }
                )
                .padding(.vertical, 10) // 设置上下边距
            
                VStack(alignment: .leading) {
                    HStack {
                        Text("本年总收入：")
                            .font(.subheadline)
                            .foregroundColor(.blackDarkMode)
                        Text("¥\(homeStore.homeDto.yearIncome)")
                            .font(.headline)
                            .foregroundColor(.green)
                    }

                    HStack {
                        Text("本年总支出：")
                            .font(.subheadline)
                            .foregroundColor(.blackDarkMode)
                        Text("¥\(homeStore.homeDto.yearOutCome)")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                    
                    HStack {
                        Text("本年结余：")
                            .font(.subheadline)
                            .foregroundColor(.blackDarkMode)
                        Text("¥\(homeStore.homeDto.yearBalance)")
                            .font(.headline)
                            .foregroundColor(.blackDarkMode)
                    }
                }
            }
            .padding(10)
            
            // Account assets
            VStack(alignment: .leading) {
                HStack {
                    Text("账户资产").foregroundColor(.accentColor)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 10) // 设置左右边距
                .overlay(
                    HStack {
                        Rectangle().frame(width: 100, height: 1).foregroundColor(.accentColor) // 左侧横线
                        Spacer()
                        Rectangle().frame(width: 100, height: 1).foregroundColor(.accentColor) // 右侧横线
                    }
                )
                .padding(.vertical, 5) // 设置上下边距
                
                // TODO 设置页-账户 如果更新了，这里应该同步刷新！
                List {
                    ForEach(homeStore.homeDto.accounts, id: \.id) { account in
                        HStack {
                            Text(account.accountName)
                                .font(.headline)
                                .foregroundColor(.blackDarkMode)
                            Spacer()
                            Text("¥\(account.accountAsset)")
                                .font(.title3)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .padding(10)
            
            Spacer()

        }
    }
}


#Preview {
    OverView()
}
