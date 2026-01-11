//
//  overview.swift
//  EasyAccounts
//  总览页 - 深色科技风格
//  Created by 沈俊杰 on 2025/2/2.
//

import SwiftUI
import ImagePickerView

struct OverView: View {
    @StateObject var homeStore = HomeStore()
    @StateObject var detailStore = DetailStore()
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var showAccountDetail = false
    @State private var showAddFlow = false
    
    // AI 识别相关状态
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isLoading = false
    @State private var taskId = ""
    @State private var alertMessage: AlertMessage?
    
    var body: some View {
        ZStack {
            // 深色背景
            Color.themeBg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - 顶部标题栏
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("$ finance-tracker")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.themeAccent)
                        Text("// AI-powered accounting system")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.themeTextSecondary)
                    }
                    
                    Spacer()
                    
                    // + NEW 菜单按钮
                    Menu {
                        Button(action: {
                            showAddFlow = true
                        }) {
                            Label("记一笔", systemImage: "pencil")
                        }
                        
                        Button(action: {
                            showImagePicker = true
                        }) {
                            Label("AI 识别", systemImage: "camera.viewfinder")
                        }
                    } label: {
                        Text("+ NEW")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.themeAccent)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.themeBg)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // MARK: - BALANCE 卡片
                        VStack(alignment: .leading, spacing: 16) {
                            // BALANCE 标题
                            Text("BALANCE")
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(.themeAccent)
                            
                            // 总资产金额
                            Text("¥ \(homeStore.homeDto.totalAsset)")
                                .font(.system(size: 32, weight: .bold, design: .monospaced))
                                .foregroundColor(.themeAccent)
                            
                            // 收入/支出分隔区
                            HStack(spacing: 24) {
                                // 收入
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("↑ INCOME")
                                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                                        .foregroundColor(.themeTextSecondary)
                                    Text("¥\(homeStore.homeDto.yearIncome)")
                                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                                        .foregroundColor(.themeTextPrimary)
                                }
                                
                                // 支出
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("↓ EXPENSE")
                                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                                        .foregroundColor(.themeTextSecondary)
                                    Text("¥\(homeStore.homeDto.yearOutCome)")
                                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                                        .foregroundColor(.themeTextPrimary)
                                }
                                
                                Spacer()
                                
                                // 账户详情按钮
                                Button(action: {
                                    showAccountDetail = true
                                }) {
                                    Text("详情 >")
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(.themeTextSecondary)
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding(16)
                        .background(Color.themeCardBg)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.themeBorderLight, lineWidth: 1)
                        )
                        .shadow(color: Color.themeAccent.opacity(0.1), radius: 10, x: 0, y: 4)
                        .padding(.horizontal, 16)
                        
                        // MARK: - [AI] ANALYSIS 卡片
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Text("[AI]")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(.themeBlue)
                                Text("ANALYSIS")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(.themeCardBg)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.themeAccent)
                                    .cornerRadius(4)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("> 本月支出较上月减少 15%")
                                    .font(.system(size: 13, design: .monospaced))
                                    .foregroundColor(.themeTextMuted)
                                Text("> 主要节省在餐饮分类")
                                    .font(.system(size: 13, design: .monospaced))
                                    .foregroundColor(.themeTextMuted)
                                Text("> 预计月结余: ¥\(homeStore.homeDto.yearBalance)")
                                    .font(.system(size: 13, design: .monospaced))
                                    .foregroundColor(.themeTextMuted)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.themeCardBg)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.themeBorderLight, lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        
                        // MARK: - RECENT_TRANSACTIONS 标题
                        HStack {
                            Text("RECENT_TRANSACTIONS")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(.themeTextTitle)
                            
                            Spacer()
                            
                            Text("view_all >")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.themeBorder)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        
                        // MARK: - 最近交易列表
                        VStack(spacing: 8) {
                            ForEach(detailStore.flowListDto.flows.prefix(5)) { flow in
                                TransactionCard(flow: flow)
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 16)
                }
                .refreshable {
                    homeStore.loadData()
                    homeStore.loadMonthlyData(year: selectedYear)
                    detailStore.loadData()
                }
            }
        }
        .sheet(isPresented: $showAccountDetail) {
            AccountDetailSheet(accounts: homeStore.homeDto.accounts)
        }
        .sheet(isPresented: $showAddFlow) {
            // 添加流水弹窗
            AddFlowView { newFlowAddRequestDto in
                detailStore.addFlow(flowAddRequestDto: newFlowAddRequestDto)
                // 延迟刷新数据
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    detailStore.loadData()
                    homeStore.loadData()
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            // AI 识别 - 图片选择
            ImagePickerView(sourceType: .photoLibrary) { image in
                self.selectedImage = image
                self.isLoading = true
                alertMessage = AlertMessage(message: "🤖 AI 分析中...")
                
                detailStore.uploadImageAndGetTaskId(flowImg: image) { taskId in
                    DispatchQueue.main.async {
                        self.taskId = taskId
                        self.isLoading = false
                        if !taskId.isEmpty {
                            alertMessage = AlertMessage(message: "✅ 识别完成，任务ID: \(taskId)\n下拉刷新获取结果")
                        } else {
                            alertMessage = AlertMessage(message: "❌ 识别失败，请重试")
                        }
                    }
                }
            }
        }
        .alert(item: $alertMessage) { alert in
            Alert(
                title: Text("提示"),
                message: Text(alert.message),
                dismissButton: .default(Text("好"))
            )
        }
        .overlay {
            // AI 处理加载指示器
            if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .themeAccent))
                        .scaleEffect(1.2)
                    
                    Text("AI 分析中...")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.themeTextPrimary)
                }
                .padding(32)
                .background(Color.themeCardBg)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.themeAccent.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            }
        }
        .onChange(of: selectedYear) { newYear in
            homeStore.loadMonthlyData(year: newYear)
        }
    }
}

// MARK: - 交易卡片组件
struct TransactionCard: View {
    let flow: FlowListSingleDto
    
    var isIncome: Bool {
        flow.hname == "收入"
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 左侧符号
            Text(isIncome ? ">" : "-")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(isIncome ? .themeAccent : .themeTextSecondary)
                .frame(width: 24)
            
            // 中间信息
            VStack(alignment: .leading, spacing: 4) {
                Text(flow.note.isEmpty ? flow.tname : flow.note)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.themeTextPrimary)
                    .lineLimit(1)
                
                Text("[\(flow.tname)]")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.themeTextSecondary)
            }
            
            Spacer()
            
            // 右侧金额和日期
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(isIncome ? "+" : "-")\(flow.money)")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(isIncome ? .themeAccent : .themeTextPrimary)
                
                Text(flow.fdate)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.themeTextSecondary)
            }
        }
        .padding(14)
        .background(Color.themeCardBg)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.themeBorderLight, lineWidth: 1)
        )
    }
}

// MARK: - 账户详情弹窗
struct AccountDetailSheet: View {
    let accounts: [HomeAccountBean]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.themeBg.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(accounts, id: \.id) { account in
                            HStack {
                                Text(account.accountName)
                                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                                    .foregroundColor(.themeTextPrimary)
                                Spacer()
                                Text("¥\(account.accountAsset)")
                                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                                    .foregroundColor(.themeAccent)
                            }
                            .padding(16)
                            .background(Color.themeCardBg)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.themeBorderLight, lineWidth: 1)
                            )
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("账户详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.themeBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                    .foregroundColor(.themeAccent)
                }
            }
        }
    }
}

#Preview {
    OverView()
}
