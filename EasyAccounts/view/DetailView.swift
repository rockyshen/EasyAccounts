//
//  Flow.swift
//  EasyAccounts
//  流水页，我取名为：DetailView，区别于FlowView
//  FlowView是单条Flow展示的页面！
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
    case all = "全部"
    case income = "收入"
    case expense = "支出"
}

// 排序选项
enum SortOption: String, CaseIterable {
    case byTime = "按时间排序"
    case byAmount = "按金额排序"
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
        
        // 根据筛选条件过滤
        switch selectedFilter {
        case .all:
            break
        case .income:
            flows = flows.filter { $0.hname == "收入" }
        case .expense:
            flows = flows.filter { $0.hname == "支出" }
        }
        
        // 根据排序条件排序
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
            VStack(spacing: 0) {
                // MARK: - 顶部标题栏
                HStack {
                    Spacer()
                    Text("明细")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    Spacer()
                }
                .overlay(
                    HStack {
                        Spacer()
                        Button(action: {
                            showFilterSheet = true
                        }) {
                            Text("筛选")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        .padding(.trailing, 16)
                    }
                )
                .padding(.vertical, 12)
                .background(Color.accentColor)
                
                // MARK: - 筛选栏
                HStack {
                    // 左侧筛选
                    Menu {
                        ForEach(FilterOption.allCases, id: \.self) { option in
                            Button(action: {
                                selectedFilter = option
                            }) {
                                HStack {
                                    Text(option.rawValue)
                                    if selectedFilter == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(selectedFilter.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.accentColor)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.accentColor)
                        }
                    }
                    
                    Spacer()
                    
                    // 右侧排序
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
                            Text(selectedSort.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.blackDarkMode)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.whiteDarkMode)
                
                // MARK: - 流水列表（使用 List 作为主滚动容器）
                FlowListGrouped(
                    flows: filteredFlows,
                    detailStore: detailStore,
                    accountStore: accountStore,
                    actionStore: actionStore,
                    typeStore: typeStore,
                    totalIn: detailStore.flowListDto.totalIn,
                    totalOut: detailStore.flowListDto.totalOut,
                    monthBalance: monthBalance,
                    yearMonthString: yearMonthString,
                    decrementMonth: decrementMonth,
                    incrementMonth: incrementMonth,
                    makeExcel: {
                        detailStore.makeExcel { success, message in
                            alertMessage = AlertMessage(message: success ? "✅报表生成成功，已发邮件" : message)
                        }
                    }
                )
                .refreshable {
                    isLoading = true
                    detailStore.getAnalysisResult(taskId: taskId) { success, message in
                        DispatchQueue.main.async {
                            if success {
                                detailStore.loadData()
                            } else {
                                alertMessage = AlertMessage(message: message)
                            }
                            self.isLoading = false
                        }
                    }
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
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.accentColor)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
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
                // 延迟刷新数据
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
        // AI识别过程中的加载指示器
        .overlay(
            Group {
                if isLoading {
                    VStack {
                        ProgressView("处理中...")
                            .foregroundColor(.blackDarkMode)
                    }
                    .padding()
                    .background(Color.whiteDarkMode)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
            }
        )
    }
}

// MARK: - 按日期分组的流水列表
struct FlowListGrouped: View {
    var flows: [FlowListSingleDto]
    var detailStore: DetailStore
    var accountStore: AccountStore
    var actionStore: ActionStore
    var typeStore: TypeStore
    
    // 月度收支信息
    var totalIn: String
    var totalOut: String
    var monthBalance: String
    var yearMonthString: String
    var decrementMonth: () -> Void
    var incrementMonth: () -> Void
    var makeExcel: () -> Void
    
    @State private var editingFlow: FlowListSingleDto?
    @State private var deletableFlow: DeletableFlow?
    @State private var showDeleteAlert = false
    
    var body: some View {
        List {
            // MARK: - 月度收支情况 Section
            Section {
                HStack(alignment: .top, spacing: 12) {
                    // 左侧：收支统计信息
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 4) {
                            Text("收入：")
                                .font(.subheadline)
                                .foregroundColor(.blackDarkMode)
                            Text("¥\(totalIn)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                        .lineLimit(1)
                        
                        HStack(spacing: 4) {
                            Text("支出：")
                                .font(.subheadline)
                                .foregroundColor(.blackDarkMode)
                            Text("¥\(totalOut)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                        }
                        .lineLimit(1)
                        
                        HStack(spacing: 4) {
                            Text("结余：")
                                .font(.subheadline)
                                .foregroundColor(.blackDarkMode)
                            Text("¥\(monthBalance)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blackDarkMode)
                        }
                        .lineLimit(1)
                    }
                    .fixedSize(horizontal: true, vertical: false)
                    
                    Spacer()
                    
                    // 右侧：年月选择器 + 生成报表按钮（垂直排列，居中对齐）
                    VStack(alignment: .center, spacing: 10) {
                        // 年月选择器
                        HStack(spacing: 4) {
                            Button {
                                print("⬅️ 点击上个月")
                                decrementMonth()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.accentColor)
                                    .frame(width: 32, height: 32)
                                    .background(Color.accentColor.opacity(0.1))
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.caption)
                                    .foregroundColor(.accentColor)
                                Text(yearMonthString)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blackDarkMode)
                            }
                            .frame(width: 100, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.accentColor.opacity(0.5), lineWidth: 1)
                            )
                            
                            Button {
                                print("➡️ 点击下个月")
                                incrementMonth()
                            } label: {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.accentColor)
                                    .frame(width: 32, height: 32)
                                    .background(Color.accentColor.opacity(0.1))
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        // 生成报表按钮（居中）
                        Button {
                            print("📊 点击生成报表")
                            makeExcel()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.text")
                                    .font(.caption)
                                Text("生成报表")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.accentColor)
                            .cornerRadius(16)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                .padding(.horizontal, 16)
            } header: {
                HStack {
                    Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                    Text("月度收支情况")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                    Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                }
                .textCase(nil)
                .listRowInsets(EdgeInsets())
            }
            
            // MARK: - 账本概览 Section（不再按日期分组，日期已在每条记录中显示）
            Section {
                ForEach(flows) { flow in
                    FlowItemView(flow: flow)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                print("🗑️ 点击删除按钮，Flow ID: \(flow.id)")
                                deletableFlow = DeletableFlow(flow: flow)
                                showDeleteAlert = true
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                editingFlow = flow
                            } label: {
                                Label("编辑", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                }
            } header: {
                HStack {
                    Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                    Text("账本概览")
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                        .padding(.horizontal, 8)
                    Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                }
                .textCase(nil)
                .listRowInsets(EdgeInsets())
            }
        }
        .listStyle(PlainListStyle())
        .sheet(item: $editingFlow) { flow in
            let newFlowAddRequestDto = FlowAddRequestDto(
                money: flow.money,
                fDate: flow.fdate,
                createDate: "",
                actionId: actionStore.getActionIdByhame(hname: flow.hname) ?? 0,
                accountId: accountStore.getAccountIdByName(accountName: flow.aname) ?? 0,
                accountToId: 0,  // 非转账时为0
                typeId: typeStore.getTypeIdByName(typeName: flow.tname) ?? 0,
                isCollect: flow.collect,
                note: flow.note
            )
            
            AddFlowView(flowAddRequestDto: newFlowAddRequestDto) { newFlowAddRequestDto in
                detailStore.updateFlow(flowId: flow.id, flowAddRequestDto: newFlowAddRequestDto)
            }
        }
        .alert("确认删除", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) {
                deletableFlow = nil
            }
            Button("删除", role: .destructive) {
                if let flow = deletableFlow?.flow {
                    print("🗑️ 确认删除 Flow ID: \(flow.id)")
                    detailStore.deleteFlow(flowId: flow.id)
                }
                deletableFlow = nil
            }
        } message: {
            Text("您确定要删除这条流水吗？")
        }
    }
}

// MARK: - 单条流水项视图（四行布局）
struct FlowItemView: View {
    var flow: FlowListSingleDto
    
    var body: some View {
        HStack(spacing: 8) {
            // 左侧：日期、分类、账户、备注（四行垂直排列）
            VStack(alignment: .leading, spacing: 2) {
                // 第一行：日期
                Text(flow.fdate)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                // 第二行：分类
                Text(flow.tname)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blackDarkMode)
                
                // 第三行：账户
                Text(flow.aname)
                    .font(.caption)
                    .foregroundColor(.accentColor)
                
                // 第四行：备注
                if !flow.note.isEmpty {
                    Text(flow.note)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // 右侧：金额和标签（垂直居中对齐）
            VStack(alignment: .trailing, spacing: 4) {
                Text("¥\(flow.money)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blackDarkMode)
                
                Text(flow.hname)
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(flow.hname == "支出" ? Color.red : Color.green)
                    .cornerRadius(3)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.whiteDarkMode)
        .contentShape(Rectangle())  // 确保整个区域可响应手势
    }
}

#Preview {
    DetailView()
}
