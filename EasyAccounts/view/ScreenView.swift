//
//  ScreenView.swift
//  EasyAccounts
//  统计页（分类统计）
//  Created by 沈俊杰 on 2025/2/2.
//

import SwiftUI

// 收入/支出切换
enum StatType: String, CaseIterable {
    case income = "收入"
    case expense = "支出"
}

struct ScreenView: View {
    @StateObject var detailStore = DetailStore()
    
    @State private var selectedType: StatType = .income
    @State private var startYear: Int = Calendar.current.component(.year, from: Date())
    @State private var startMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var endYear: Int = Calendar.current.component(.year, from: Date())
    @State private var endMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var showConditionSheet: Bool = false
    @State private var showChartView: Bool = false
    
    // 格式化开始时间
    private var startDateString: String {
        return String(format: "%04d年%02d月", startYear, startMonth)
    }
    
    // 格式化结束时间
    private var endDateString: String {
        return String(format: "%04d年%02d月", endYear, endMonth)
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
    
    // 按分类汇总
    private var categoryStats: [(name: String, amount: Double, percent: Double)] {
        var stats: [String: Double] = [:]
        
        for flow in filteredFlows {
            let amount = Double(flow.money) ?? 0
            stats[flow.tname, default: 0] += amount
        }
        
        let total = totalAmount
        return stats.map { (name: $0.key, amount: $0.value, percent: total > 0 ? ($0.value / total) * 100 : 0) }
            .sorted { $0.amount > $1.amount }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - 顶部标题栏
            HStack {
                Spacer()
                Text("分类统计")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                Spacer()
            }
            .overlay(
                HStack {
                    Spacer()
                    Button(action: {
                        // 单项分类功能
                    }) {
                        Text("单项分类")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 16)
                }
            )
            .padding(.vertical, 12)
            .background(Color.accentColor)
            
            // MARK: - 时间范围和统计信息
            VStack(spacing: 12) {
                HStack(alignment: .top) {
                    // 左侧时间和总计
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Text("开始时间：")
                                .font(.subheadline)
                                .foregroundColor(.blackDarkMode)
                            Text(startDateString)
                                .font(.subheadline)
                                .foregroundColor(.blackDarkMode)
                        }
                        
                        HStack(spacing: 8) {
                            Text("结束时间：")
                                .font(.subheadline)
                                .foregroundColor(.blackDarkMode)
                            Text(endDateString)
                                .font(.subheadline)
                                .foregroundColor(.blackDarkMode)
                        }
                        
                        HStack(spacing: 8) {
                            Text("总计：")
                                .font(.subheadline)
                                .foregroundColor(.blackDarkMode)
                            Text("¥\(String(format: "%.2f", totalAmount))")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(selectedType == .income ? .green : .red)
                        }
                    }
                    
                    Spacer()
                    
                    // 右侧按钮
                    VStack(spacing: 8) {
                        Button(action: {
                            showConditionSheet = true
                        }) {
                            Text("统计条件")
                                .font(.caption)
                                .foregroundColor(.blackDarkMode)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        Button(action: {
                            showChartView = true
                        }) {
                            Text("查看图表")
                                .font(.caption)
                                .foregroundColor(.blackDarkMode)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 16)
            .background(Color.whiteDarkMode)
            
            // MARK: - 收入/支出切换 Tab
            HStack(spacing: 0) {
                ForEach(StatType.allCases, id: \.self) { type in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedType = type
                        }
                    }) {
                        Text(type.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedType == type ? .white : .blackDarkMode)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(selectedType == type ? Color.accentColor : Color.clear)
                    }
                }
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            Divider()
            
            // MARK: - 分类列表（支持下拉刷新）
            List {
                if categoryStats.isEmpty {
                    HStack {
                        Spacer()
                        Text("暂无数据")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.vertical, 50)
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(categoryStats, id: \.name) { stat in
                        HStack {
                            // 分类名称
                            Text(stat.name)
                                .font(.headline)
                                .foregroundColor(.blackDarkMode)
                            
                            Spacer()
                            
                            // 金额
                            Text("¥\(String(format: "%.2f", stat.amount))")
                                .font(.subheadline)
                                .foregroundColor(.blackDarkMode)
                            
                            // 百分比标签
                            Text("\(String(format: "%.2f", stat.percent))%")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(selectedType == .income ? Color.green : Color.red)
                                .cornerRadius(4)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .refreshable {
                detailStore.loadData()
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        // 统计条件弹窗
        .sheet(isPresented: $showConditionSheet) {
            StatConditionSheet(
                startYear: $startYear,
                startMonth: $startMonth,
                endYear: $endYear,
                endMonth: $endMonth
            )
        }
        // 图表弹窗
        .sheet(isPresented: $showChartView) {
            ChartView(categoryStats: categoryStats, selectedType: selectedType)
        }
    }
}

// MARK: - 统计条件设置弹窗
struct StatConditionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var startYear: Int
    @Binding var startMonth: Int
    @Binding var endYear: Int
    @Binding var endMonth: Int
    
    let years = Array(2020...2030)
    let months = Array(1...12)
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("开始时间")) {
                    Picker("年份", selection: $startYear) {
                        ForEach(years, id: \.self) { year in
                            Text("\(String(year))年").tag(year)
                        }
                    }
                    Picker("月份", selection: $startMonth) {
                        ForEach(months, id: \.self) { month in
                            Text("\(month)月").tag(month)
                        }
                    }
                }
                
                Section(header: Text("结束时间")) {
                    Picker("年份", selection: $endYear) {
                        ForEach(years, id: \.self) { year in
                            Text("\(String(year))年").tag(year)
                        }
                    }
                    Picker("月份", selection: $endMonth) {
                        ForEach(months, id: \.self) { month in
                            Text("\(month)月").tag(month)
                        }
                    }
                }
            }
            .navigationTitle("统计条件")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("确定") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 图表视图
struct ChartView: View {
    @Environment(\.dismiss) private var dismiss
    let categoryStats: [(name: String, amount: Double, percent: Double)]
    let selectedType: StatType
    
    // 计算最大金额用于条形图比例
    private var maxAmount: Double {
        categoryStats.map { $0.amount }.max() ?? 1
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // 标题
                    Text(selectedType == .income ? "收入分类统计" : "支出分类统计")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blackDarkMode)
                        .padding(.top, 20)
                    
                    // 条形图
                    VStack(spacing: 12) {
                        ForEach(categoryStats, id: \.name) { stat in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(stat.name)
                                        .font(.subheadline)
                                        .foregroundColor(.blackDarkMode)
                                    Spacer()
                                    Text("¥\(String(format: "%.2f", stat.amount))")
                                        .font(.subheadline)
                                        .foregroundColor(.blackDarkMode)
                                }
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        // 背景条
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 20)
                                        
                                        // 数值条
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(selectedType == .income ? Color.green : Color.red)
                                            .frame(width: geometry.size.width * CGFloat(stat.amount / maxAmount), height: 20)
                                        
                                        // 百分比文字
                                        Text("\(String(format: "%.1f", stat.percent))%")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                            .padding(.leading, 8)
                                    }
                                }
                                .frame(height: 20)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
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
    ScreenView()
}
