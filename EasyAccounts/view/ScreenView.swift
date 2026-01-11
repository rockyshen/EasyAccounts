//
//  ScreenView.swift
//  EasyAccounts
//  统计页（分类统计）- 深色科技风格
//  Created by 沈俊杰 on 2025/2/2.
//

import SwiftUI

// 收入/支出切换
enum StatType: String, CaseIterable {
    case expense = "EXPENSE"
    case income = "INCOME"
}

struct ScreenView: View {
    @StateObject var detailStore = DetailStore()
    
    @State private var selectedType: StatType = .expense
    @State private var startYear: Int = Calendar.current.component(.year, from: Date())
    @State private var startMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var endYear: Int = Calendar.current.component(.year, from: Date())
    @State private var endMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var showConditionSheet: Bool = false
    @State private var showChartView: Bool = false
    
    // 分类颜色
    private let categoryColors: [Color] = [
        Color(hex: "C27AFF"),  // 紫色
        Color(hex: "51A2FF"),  // 蓝色
        Color(hex: "05DF72"),  // 绿色
        Color(hex: "FDC700"),  // 黄色
        Color(hex: "EC4899"),  // 粉色
        Color(hex: "06B6D4"),  // 青色
        Color(hex: "FF6467"),  // 红色
        Color(hex: "FF8904"),  // 橙色
    ]
    
    // 格式化时间范围
    private var dateRangeString: String {
        return String(format: "%04d.%02d - %04d.%02d", startYear, startMonth, endYear, endMonth)
    }
    
    // 根据选择的类型过滤流水
    private var filteredFlows: [FlowListSingleDto] {
        return detailStore.flowListDto.flows.filter { flow in
            selectedType == .income ? flow.hname == "收入" : flow.hname == "支出"
        }
    }
    
    // 计算总金额
    private var totalAmount: Double {
        filteredFlows.reduce(0) { $0 + (Double($1.money) ?? 0) }
    }
    
    // 计算总收入
    private var totalIncome: Double {
        detailStore.flowListDto.flows
            .filter { $0.hname == "收入" }
            .reduce(0) { $0 + (Double($1.money) ?? 0) }
    }
    
    // 计算总支出
    private var totalExpense: Double {
        detailStore.flowListDto.flows
            .filter { $0.hname == "支出" }
            .reduce(0) { $0 + (Double($1.money) ?? 0) }
    }
    
    // 支出趋势（模拟）
    private var spendingTrend: String {
        let trend = totalIncome > 0 ? ((totalExpense / totalIncome) * 100) : 0
        return trend > 50 ? "+\(Int(trend - 50))%" : "-\(Int(50 - trend))%"
    }
    
    // 预算使用率
    private var budgetUsed: String {
        let used = totalIncome > 0 ? ((totalExpense / totalIncome) * 100) : 0
        return "\(min(Int(used), 100))%"
    }
    
    // 按分类汇总
    private var categoryStats: [(name: String, amount: Double, percent: Double, color: Color)] {
        var stats: [String: Double] = [:]
        
        for flow in filteredFlows {
            let amount = Double(flow.money) ?? 0
            stats[flow.tname, default: 0] += amount
        }
        
        let total = totalAmount
        let sorted = stats.map { (name: $0.key, amount: $0.value, percent: total > 0 ? ($0.value / total) * 100 : 0) }
            .sorted { $0.amount > $1.amount }
        
        return sorted.enumerated().map { index, stat in
            (name: stat.name, amount: stat.amount, percent: stat.percent, color: categoryColors[index % categoryColors.count])
        }
    }
    
    var body: some View {
        ZStack {
            // 深色背景
            Color.themeBg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - 顶部标题栏（固定）
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("$ ai-analysis --deep")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.themeAccent)
                        Text("// Financial insights powered by AI")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.themeTextSecondary)
                    }
                    
                    Spacer()
                    
                    // 设置按钮
                    Button(action: {
                        showConditionSheet = true
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 18))
                            .foregroundColor(.themeTextSecondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.themeBg)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // MARK: - 四个统计卡片
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        StatCard(
                            label: "spending_trend",
                            value: spendingTrend,
                            valueColor: spendingTrend.hasPrefix("+") ? .themeExpense : .themeAccent
                        )
                        
                        StatCard(
                            label: "saving_advice",
                            value: "¥\(Int(max(0, totalIncome - totalExpense)))/mo",
                            valueColor: .themeAccent
                        )
                        
                        StatCard(
                            label: "budget_used",
                            value: budgetUsed,
                            valueColor: .themeTextPrimary
                        )
                        
                        StatCard(
                            label: "invest_ready",
                            value: "¥\(Int(max(0, totalIncome - totalExpense)))",
                            valueColor: .themeAccent
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    // MARK: - 收入/支出切换
                    HStack(spacing: 8) {
                        ForEach(StatType.allCases, id: \.self) { type in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedType = type
                                }
                            }) {
                                Text(type.rawValue)
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(selectedType == type ? .black : .themeTextSecondary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedType == type ? Color.themeAccent : Color.clear)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedType == type ? Color.clear : Color.themeBorderLight, lineWidth: 1)
                                    )
                            }
                        }
                        
                        Spacer()
                        
                        // 时间范围
                        Text(dateRangeString)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.themeTextSecondary)
                    }
                    .padding(.horizontal, 16)
                    
                    // MARK: - 分类分析卡片
                    VStack(spacing: 16) {
                        // 标题
                        HStack {
                            Image(systemName: "chart.pie.fill")
                                .foregroundColor(.themeBlue)
                            Text("CATEGORY_ANALYSIS")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(.themeTextTitle)
                            Spacer()
                            
                            Button(action: {
                                showChartView = true
                            }) {
                                Text("expand >")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.themeTextSecondary)
                            }
                        }
                        
                        if categoryStats.isEmpty {
                            Text("// No data available")
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(.themeTextSecondary)
                                .padding(.vertical, 40)
                        } else {
                            // 圆环图
                            DonutChart(data: categoryStats, totalAmount: totalAmount)
                                .frame(height: 180)
                            
                            // 分类列表
                            VStack(spacing: 8) {
                                ForEach(categoryStats.prefix(6), id: \.name) { stat in
                                    CategoryRow(
                                        color: stat.color,
                                        name: stat.name,
                                        amount: stat.amount,
                                        percent: stat.percent
                                    )
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.themeCardBg)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.themeBorderLight, lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, 8)
            }
            .refreshable {
                loadStatData()
            }
            }
        }
        .onAppear {
            loadStatData()
        }
        .sheet(isPresented: $showConditionSheet) {
            StatConditionSheet(
                startYear: $startYear,
                startMonth: $startMonth,
                endYear: $endYear,
                endMonth: $endMonth,
                onConfirm: {
                    loadStatData()
                }
            )
        }
        .sheet(isPresented: $showChartView) {
            AnalysisChartView(categoryStats: categoryStats, selectedType: selectedType, totalAmount: totalAmount)
        }
    }
    
    private func loadStatData() {
        detailStore.loadDataForRange(
            startYear: startYear,
            startMonth: startMonth,
            endYear: endYear,
            endMonth: endMonth
        )
    }
}

// MARK: - 统计卡片组件
struct StatCard: View {
    let label: String
    let value: String
    var valueColor: Color = .themeTextPrimary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.themeTextSecondary)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(valueColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.themeCardBg)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.themeBorderLight, lineWidth: 1)
        )
    }
}

// MARK: - 圆环图组件
struct DonutChart: View {
    let data: [(name: String, amount: Double, percent: Double, color: Color)]
    let totalAmount: Double
    
    var body: some View {
        ZStack {
            // 圆环
            ForEach(0..<data.count, id: \.self) { index in
                let startAngle = startAngle(for: index)
                let endAngle = endAngle(for: index)
                
                Circle()
                    .trim(from: startAngle, to: endAngle)
                    .stroke(data[index].color, lineWidth: 24)
                    .rotationEffect(.degrees(-90))
            }
            
            // 中心文字
            VStack(spacing: 4) {
                Text("¥\(Int(totalAmount))")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.themeTextPrimary)
                Text("total")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.themeTextSecondary)
            }
        }
        .padding(24)
    }
    
    private func startAngle(for index: Int) -> CGFloat {
        let precedingPercent = data.prefix(index).reduce(0) { $0 + $1.percent }
        return CGFloat(precedingPercent / 100)
    }
    
    private func endAngle(for index: Int) -> CGFloat {
        let precedingPercent = data.prefix(index + 1).reduce(0) { $0 + $1.percent }
        return CGFloat(precedingPercent / 100)
    }
}

// MARK: - 分类行组件
struct CategoryRow: View {
    let color: Color
    let name: String
    let amount: Double
    let percent: Double
    
    var body: some View {
        HStack(spacing: 12) {
            // 颜色标识
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 16, height: 16)
            
            // 分类名称
            Text(name)
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.themeTextPrimary)
            
            Spacer()
            
            // 金额
            Text("¥\(Int(amount))")
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(.themeAccent)
            
            // 百分比
            Text(String(format: "%.1f%%", percent))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.themeTextSecondary)
                .frame(width: 50, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 统计条件设置弹窗
struct StatConditionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var startYear: Int
    @Binding var startMonth: Int
    @Binding var endYear: Int
    @Binding var endMonth: Int
    var onConfirm: () -> Void
    
    let years = Array(2020...2030)
    let months = Array(1...12)
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.themeBg.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // 开始时间
                    VStack(alignment: .leading, spacing: 12) {
                        Text("# START_DATE")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.themeTextSecondary)
                        
                        HStack(spacing: 12) {
                            Picker("Year", selection: $startYear) {
                                ForEach(years, id: \.self) { year in
                                    Text("\(String(year))").tag(year)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 100, height: 100)
                            .clipped()
                            
                            Picker("Month", selection: $startMonth) {
                                ForEach(months, id: \.self) { month in
                                    Text(String(format: "%02d", month)).tag(month)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 80, height: 100)
                            .clipped()
                        }
                    }
                    .padding(16)
                    .background(Color.themeCardBg)
                    .cornerRadius(12)
                    
                    // 结束时间
                    VStack(alignment: .leading, spacing: 12) {
                        Text("# END_DATE")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.themeTextSecondary)
                        
                        HStack(spacing: 12) {
                            Picker("Year", selection: $endYear) {
                                ForEach(years, id: \.self) { year in
                                    Text("\(String(year))").tag(year)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 100, height: 100)
                            .clipped()
                            
                            Picker("Month", selection: $endMonth) {
                                ForEach(months, id: \.self) { month in
                                    Text(String(format: "%02d", month)).tag(month)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 80, height: 100)
                            .clipped()
                        }
                    }
                    .padding(16)
                    .background(Color.themeCardBg)
                    .cornerRadius(12)
                    
                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("$ set-range")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.themeAccent)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.themeTextSecondary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        onConfirm()
                        dismiss()
                    }) {
                        Text("APPLY")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.themeAccent)
                    }
                }
            }
            .toolbarBackground(Color.themeBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

// MARK: - 分析图表视图
struct AnalysisChartView: View {
    @Environment(\.dismiss) private var dismiss
    let categoryStats: [(name: String, amount: Double, percent: Double, color: Color)]
    let selectedType: StatType
    let totalAmount: Double
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.themeBg.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 大圆环图
                        DonutChart(data: categoryStats, totalAmount: totalAmount)
                            .frame(height: 240)
                        
                        // 分类详情列表
                        VStack(spacing: 12) {
                            ForEach(categoryStats, id: \.name) { stat in
                                HStack(spacing: 12) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(stat.color)
                                        .frame(width: 20, height: 20)
                                    
                                    Text(stat.name)
                                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                                        .foregroundColor(.themeTextPrimary)
                                    
                                    Spacer()
                                    
                                    Text("¥\(String(format: "%.2f", stat.amount))")
                                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                                        .foregroundColor(.themeAccent)
                                    
                                    Text(String(format: "%.1f%%", stat.percent))
                                        .font(.system(size: 13, design: .monospaced))
                                        .foregroundColor(.themeTextSecondary)
                                        .frame(width: 60, alignment: .trailing)
                                }
                                .padding(16)
                                .background(Color.themeCardBg)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("$ \(selectedType.rawValue.lowercased())_breakdown")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.themeAccent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text("CLOSE")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.themeTextSecondary)
                    }
                }
            }
            .toolbarBackground(Color.themeBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

#Preview {
    ScreenView()
}
