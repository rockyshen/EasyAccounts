//
//  overview.swift
//  EasyAccounts
//  总览页
//  Created by 沈俊杰 on 2025/2/2.
//

import SwiftUI

struct OverView: View {
    @StateObject var homeStore = HomeStore()
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var showAccountDetail = false
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - 顶部标题栏
            Text("总览")
                .font(.headline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.accentColor)
                .foregroundColor(.white)
            
            ScrollView {
                VStack(spacing: 16) {
                    // MARK: - 总资产卡片
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text("总资产：")
                                    .font(.title3)
                                    .foregroundColor(.blackDarkMode)
                                Text("¥\(homeStore.homeDto.totalAsset)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blackDarkMode)
                            }
                            HStack(spacing: 8) {
                                Text("净资产：")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("¥\(homeStore.homeDto.netAsset)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                        
                        // 账户详情按钮
                        Button(action: {
                            showAccountDetail = true
                        }) {
                            Text("账户详情")
                                .font(.subheadline)
                                .foregroundColor(.accentColor)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.accentColor, lineWidth: 1)
                                )
                        }
                    }
                    .padding()
                    .background(Color.whiteDarkMode)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // MARK: - 年度收支区域
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Text("年度总收入：")
                                    .font(.subheadline)
                                    .foregroundColor(.blackDarkMode)
                                Text("¥\(homeStore.homeDto.yearIncome)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.green)
                            }
                            
                            HStack(spacing: 8) {
                                Text("年度总支出：")
                                    .font(.subheadline)
                                    .foregroundColor(.blackDarkMode)
                                Text("¥\(homeStore.homeDto.yearOutCome)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.red)
                            }
                            
                            HStack(spacing: 8) {
                                Text("年度结余：")
                                    .font(.subheadline)
                                    .foregroundColor(.blackDarkMode)
                                Text("¥\(homeStore.homeDto.yearBalance)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blackDarkMode)
                            }
                        }
                        
                        Spacer()
                        
                        // 年份选择器
                        HStack(spacing: 0) {
                            Button(action: {
                                selectedYear -= 1
                            }) {
                                Image(systemName: "minus")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .frame(width: 30, height: 30)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("\(String(selectedYear))")
                                    .font(.subheadline)
                                    .foregroundColor(.blackDarkMode)
                            }
                            .frame(width: 70, height: 30)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            
                            Button(action: {
                                selectedYear += 1
                            }) {
                                Image(systemName: "plus")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .frame(width: 30, height: 30)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding()
                    .background(Color.whiteDarkMode)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // MARK: - 月度概览表格
                    VStack(spacing: 0) {
                        // 表格标题
                        Text("\(String(selectedYear))年月度概览")
                            .font(.subheadline)
                            .foregroundColor(.accentColor)
                            .padding(.vertical, 12)
                        
                        // 表头
                        HStack {
                            Text("月份")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blackDarkMode)
                                .frame(width: 50, alignment: .leading)
                            
                            Text("收入")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blackDarkMode)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text("支出")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blackDarkMode)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text("结余")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blackDarkMode)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.05))
                        
                        Divider()
                        
                        // 表格数据行（从后端动态获取）
                        if homeStore.isLoadingMonthly {
                            HStack {
                                Spacer()
                                ProgressView("加载中...")
                                    .padding()
                                Spacer()
                            }
                        }
                        
                        ForEach(homeStore.monthlyDataList) { data in
                            VStack(spacing: 0) {
                                HStack {
                                    Text(data.month)
                                        .font(.subheadline)
                                        .foregroundColor(.blackDarkMode)
                                        .frame(width: 50, alignment: .leading)
                                    
                                    Text("¥\(data.income)")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    
                                    Text("¥\(data.expense)")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    
                                    Text("¥\(data.balance)")
                                        .font(.subheadline)
                                        .foregroundColor(data.balance.hasPrefix("-") ? .red : .blackDarkMode)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                                
                                Divider()
                            }
                        }
                    }
                    .background(Color.whiteDarkMode)
                    
                    Spacer(minLength: 50)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .refreshable {
                // 刷新首页数据和月度数据
                homeStore.loadData()
                homeStore.loadMonthlyData(year: selectedYear)
            }
        }
        .sheet(isPresented: $showAccountDetail) {
            // 账户详情弹窗
            AccountDetailSheet(accounts: homeStore.homeDto.accounts)
        }
        .onChange(of: selectedYear) { newYear in
            // 切换年份时重新加载月度数据
            homeStore.loadMonthlyData(year: newYear)
        }
    }
}

// MARK: - 账户详情弹窗
struct AccountDetailSheet: View {
    let accounts: [HomeAccountBean]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(accounts, id: \.id) { account in
                    HStack {
                        Text(account.accountName)
                            .font(.headline)
                            .foregroundColor(.blackDarkMode)
                        Spacer()
                        Text("¥\(account.accountAsset)")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("账户详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    OverView()
}
