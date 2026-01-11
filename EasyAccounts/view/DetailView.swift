//
//  Flow.swift
//  EasyAccounts
//  流水页 - 深色科技风格
//  Created by 沈俊杰 on 2025/2/2.
//

import SwiftUI
import ImagePickerView

struct AlertMessage: Identifiable {
    let id = UUID()
    let message: String
}

// 筛选选项
enum FilterOption: String, CaseIterable {
    case all = "ALL"
    case income = "INCOME"
    case expense = "EXPENSE"
}

// 排序选项
enum SortOption: String, CaseIterable {
    case byTime = "TIME"
    case byAmount = "AMOUNT"
}

struct DetailView: View {
    @StateObject var detailStore = DetailStore()
    @StateObject var accountStore = AccountStore()
    @StateObject var actionStore = ActionStore()
    @StateObject var typeStore = TypeStore()
    
    @State private var date = Date()
    @State private var showingDatePicker = false
    @State private var isShowingAddFlowView: Bool = false
    @State private var showFilterSheet: Bool = false
    
    @State private var selectedDate = Date() {
        didSet { detailStore.updateYearAndMonth(selectDate: selectedDate) }
    }
    
    @State private var year: Int
    @State private var month: Int
    
    // 筛选和排序
    @State private var selectedFilter: FilterOption = .all
    @State private var selectedSort: SortOption = .byTime
    
    @State var image: UIImage?
    @State var showImagePicker: Bool = false
    
    // AI识别状态
    @State private var responseMessage = ""
    @State var isLoading: Bool = false
    @State private var showProcessingAlert = false
    @State private var showCompletionAlert = false
    @State private var taskId: String = ""
    @State private var alertMessage: AlertMessage?
    
    // 初始化为系统当前年月
    init() {
        let currentDate = Date()
        let calendar = Calendar.current
        self._year = State(initialValue: calendar.component(.year, from: currentDate))
        self._month = State(initialValue: calendar.component(.month, from: currentDate))
    }
    
    // 月份选择器计算方法
    private func updateSelectedDate() {
        if let newDate = Calendar.current.date(from: DateComponents(year: year, month: month)) {
            selectedDate = newDate
        }
    }
    
    private func incrementMonth() {
        month += 1
        if month > 12 {
            month = 1
            year += 1
        }
        updateSelectedDate()
    }
    
    private func decrementMonth() {
        month -= 1
        if month < 1 {
            month = 12
            year -= 1
        }
        updateSelectedDate()
    }
    
    // 格式化年月显示
    private var yearMonthString: String {
        return String(format: "%04d-%02d", year, month)
    }
    
    // 计算当月结余
    private var monthBalance: String {
        let income = Double(detailStore.flowListDto.totalIn) ?? 0
        let expense = Double(detailStore.flowListDto.totalOut) ?? 0
        let balance = income - expense
        return String(format: "%.2f", balance)
    }
    
    // 筛选后的流水
    private var filteredFlows: [FlowListSingleDto] {
        var flows = detailStore.flowListDto.flows
        
        switch selectedFilter {
        case .all:
            break
        case .income:
            flows = flows.filter { $0.hname == "收入" }
        case .expense:
            flows = flows.filter { $0.hname == "支出" }
        }
        
        switch selectedSort {
        case .byTime:
            flows.sort { $0.fdate > $1.fdate }
        case .byAmount:
            flows.sort { (Double($0.money) ?? 0) > (Double($1.money) ?? 0) }
        }
        
        return flows
    }
    
    var body: some View {
        ZStack {
            // 深色背景
            Color.themeBg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - 顶部标题栏
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("$ transactions --all")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.themeAccent)
                        
                        Spacer()
                        
                        // 月份切换
                        HStack(spacing: 8) {
                            Button(action: decrementMonth) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.themeTextSecondary)
                            }
                            
                            Text(yearMonthString)
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                                .foregroundColor(.themeTextPrimary)
                            
                            Button(action: incrementMonth) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.themeTextSecondary)
                            }
                        }
                    }
                    
                    Text("// Complete transaction history")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.themeTextSecondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.themeBg)
                
                // MARK: - 月度统计卡片
                HStack(spacing: 24) {
                    // 收入
                    VStack(alignment: .leading, spacing: 4) {
                        Text("↑ INCOME")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.themeTextSecondary)
                        Text("¥\(detailStore.flowListDto.totalIn)")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.themeIncome)
                    }
                    
                    // 支出
                    VStack(alignment: .leading, spacing: 4) {
                        Text("↓ EXPENSE")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.themeTextSecondary)
                        Text("¥\(detailStore.flowListDto.totalOut)")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.themeExpense)
                    }
                    
                    // 结余
                    VStack(alignment: .leading, spacing: 4) {
                        Text("= BALANCE")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.themeTextSecondary)
                        Text("¥\(monthBalance)")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.themeTextPrimary)
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(Color.themeCardBg)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.themeBorderLight, lineWidth: 1)
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
                
                // MARK: - 筛选栏
                HStack {
                    // 筛选按钮组
                    HStack(spacing: 8) {
                        ForEach(FilterOption.allCases, id: \.self) { option in
                            Button(action: {
                                selectedFilter = option
                            }) {
                                Text(option.rawValue)
                                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                                    .foregroundColor(selectedFilter == option ? .black : .themeTextSecondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedFilter == option ? Color.themeAccent : Color.clear)
                                    .cornerRadius(6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(selectedFilter == option ? Color.clear : Color.themeBorderLight, lineWidth: 1)
                                    )
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // 排序
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button(action: {
                                selectedSort = option
                            }) {
                                HStack {
                                    Text(option.rawValue)
                                    if selectedSort == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text("sort: \(selectedSort.rawValue)")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.themeTextSecondary)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10))
                                .foregroundColor(.themeTextSecondary)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
                
                // MARK: - 流水列表
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredFlows) { flow in
                            DetailFlowCard(
                                flow: flow,
                                onEdit: {
                                    // 编辑处理
                                },
                                onDelete: {
                                    detailStore.deleteFlow(flowId: flow.id)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
                .refreshable {
                    detailStore.loadData()
                }
            }
            
            // MARK: - 右下角浮动按钮
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Menu {
                        Button(action: {
                            isShowingAddFlowView.toggle()
                        }) {
                            Label("记一笔", systemImage: "pencil")
                        }
                        
                        Button(action: {
                            showImagePicker.toggle()
                        }) {
                            Label("AI识别", systemImage: "camera")
                        }
                        
                        Button(action: {
                            detailStore.makeExcel { success, message in
                                alertMessage = AlertMessage(message: success ? "✅报表生成成功" : message)
                            }
                        }) {
                            Label("生成报表", systemImage: "doc.text")
                        }
                    } label: {
                        Text("+")
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundColor(.black)
                            .frame(width: 56, height: 56)
                            .background(Color.themeAccent)
                            .clipShape(Circle())
                            .shadow(color: Color.themeAccent.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        // 弹出：新增Flow页面
        .sheet(isPresented: $isShowingAddFlowView) {
            AddFlowView { newFlowAddRequestDto in
                detailStore.addFlow(flowAddRequestDto: newFlowAddRequestDto)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    detailStore.loadData()
                }
            }
        }
        // 弹出：图片选择页
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(sourceType: .photoLibrary) { image in
                self.image = image
                self.isLoading = true
                alertMessage = AlertMessage(message: "🤖️处理中...")
                
                detailStore.uploadImageAndGetTaskId(flowImg: image) { taskId in
                    DispatchQueue.main.async {
                        self.taskId = taskId
                        self.isLoading = false
                        alertMessage = AlertMessage(message: "任务ID：\(taskId)")
                    }
                }
            }
        }
        // Alert 弹窗
        .alert(item: $alertMessage) { alert in
            Alert(title: Text("提示"), message: Text(alert.message), dismissButton: .default(Text("好")))
        }
        // 加载指示器
        .overlay(
            Group {
                if isLoading {
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .themeAccent))
                        Text("处理中...")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.themeTextSecondary)
                            .padding(.top, 8)
                    }
                    .padding(24)
                    .background(Color.themeCardBg)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.themeBorderLight, lineWidth: 1)
                    )
                }
            }
        )
    }
}

// MARK: - 流水卡片组件
struct DetailFlowCard: View {
    let flow: FlowListSingleDto
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    @State private var showDeleteAlert = false
    
    var isIncome: Bool {
        flow.hname == "收入"
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 左侧符号
            Text(isIncome ? ">" : "-")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(isIncome ? .themeAccent : .themeTextSecondary)
                .frame(width: 28)
            
            // 中间信息
            VStack(alignment: .leading, spacing: 4) {
                Text(flow.note.isEmpty ? flow.tname : flow.note)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.themeTextPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text("[\(flow.tname)]")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.themeTextSecondary)
                    
                    Text(flow.aname)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.themeBlue)
                }
            }
            
            Spacer()
            
            // 右侧金额和日期
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(isIncome ? "+" : "-")\(flow.money)")
                    .font(.system(size: 17, weight: .bold, design: .monospaced))
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
        .contextMenu {
            Button(action: onEdit) {
                Label("编辑", systemImage: "pencil")
            }
            Button(role: .destructive, action: {
                showDeleteAlert = true
            }) {
                Label("删除", systemImage: "trash")
            }
        }
        .alert("确认删除", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("您确定要删除这条流水吗？")
        }
    }
}

#Preview {
    DetailView()
}
