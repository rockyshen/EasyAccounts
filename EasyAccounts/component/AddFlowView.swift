//
//  AddFlowView.swift
//  EasyAccounts
//  记一笔，跳转到本页面
//  Created by 沈俊杰 on 2025/2/8.
//

import SwiftUI

struct AddFlowView: View {
    // 日期格式化器
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // 属性已经设置默认值了，就不用实例化时传递了
    @State var flowAddRequestDto: FlowAddRequestDto
    
    @Environment(\.dismiss) private var dismiss
    
    // Date 类型转换为 String
    @State private var selectedDate = Date()
    
    // 初始化方法：设置默认日期
    init(flowAddRequestDto: FlowAddRequestDto = .init(
        money: "",
        fDate: Self.dateFormatter.string(from: Date()),
        createDate: Self.dateFormatter.string(from: Date()),
        actionId: 0,      // 默认为0，后续由 onAppear 设置为列表第一项
        accountId: 0,     // 默认为0，后续由 onAppear 设置为列表第一项
        accountToId: 0,   // 非转账时为0
        typeId: 0,        // 默认为0，后续由 onAppear 设置为列表第一项
        isCollect: false,
        note: ""
    ), completion: @escaping (FlowAddRequestDto) -> Void) {
        self._flowAddRequestDto = State(initialValue: flowAddRequestDto)
        self.completion = completion
        
        // 如果传入的 fDate 不为空，解析为 Date 用于 DatePicker
        if !flowAddRequestDto.fDate.isEmpty,
           let date = Self.dateFormatter.date(from: flowAddRequestDto.fDate) {
            self._selectedDate = State(initialValue: date)
        }
        
        // 如果是编辑已有流水（money不为空），则不需要设置初始值
        self._needsInitialSetup = State(initialValue: flowAddRequestDto.money.isEmpty)
    }
    
    // 回调函数
    let completion: (FlowAddRequestDto) -> Void
    
    @StateObject var actionStore = ActionStore()
    @StateObject var accountStore = AccountStore()
    @StateObject var typeStore = TypeStore()
    
    // 标记是否需要设置初始值（仅在新增时需要，编辑时不需要）
    @State private var needsInitialSetup = true
    
    var body: some View {
        NavigationView {
            Form {
                HStack {
                    Text("账单金额")
                        .padding(.trailing, 20)
                    TextField("请输入金额", text: $flowAddRequestDto.money)
                        .keyboardType(.decimalPad)
                        .textInputAutocapitalization(.none)
                        .background(Color.white)
                        .cornerRadius(8)
                }
                Picker("选择收支", selection: $flowAddRequestDto.actionId) {
                    ForEach(actionStore.actions, id: \.id) { action in
                        Text(action.hname).tag(action.id)
                    }
                }
                .pickerStyle(DefaultPickerStyle())
                Picker("选择账户", selection: $flowAddRequestDto.accountId) {
                    ForEach(accountStore.accountResponseDtoList, id: \.id) { account in
                        Text(account.name).tag(account.id ?? 0)  // Int? 转为 Int
                    }
                }
                .pickerStyle(DefaultPickerStyle())
                Picker("账单分类", selection: $flowAddRequestDto.typeId) {
                    ForEach(typeStore.typeListResponseDtoList, id: \.id) { type in
                        Text(type.tname).tag(type.id)
                    }
                }
                .pickerStyle(DefaultPickerStyle())
                DatePicker("账单日期", selection: $selectedDate, displayedComponents: .date)
                    .onChange(of: selectedDate) { newDate in
                        flowAddRequestDto.fDate = Self.dateFormatter.string(from: newDate)
                    }
                Toggle("是否收藏", isOn: $flowAddRequestDto.isCollect)
                HStack{
                    Text("备注").padding(.trailing, 30)
                    TextField("备注", text: $flowAddRequestDto.note)
                        .textInputAutocapitalization(.none)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                }
//                Button("追加分账单") {
//                    // 处理追加分账单逻辑
//                }
//                .padding()
//                .background(Color.orange)
//                .foregroundColor(.white)
//                .cornerRadius(8)
                HStack{
                    Spacer()
                    Button("提交") {
                        // 确保日期字段有值
                        var submitDto = flowAddRequestDto
                        submitDto.fDate = Self.dateFormatter.string(from: selectedDate)
                        submitDto.createDate = Self.dateFormatter.string(from: Date())
                        // 非转账情况下，accountToId 设为 0
                        submitDto.accountToId = 0
                        
                        dismiss()
                        completion(submitDto)
                        print("📝 提交流水: \(submitDto)")
                    }
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    Spacer()
                }
            }
            .navigationTitle("更新流水")
            .onAppear {
                // 如果是新增流水（money为空），设置初始值为列表第一项
                if needsInitialSetup {
                    setupInitialValues()
                }
            }
            // 监听数据加载完成，更新初始值（检查当前值是否在列表中存在）
            .onChange(of: actionStore.actions.count) { _ in
                if needsInitialSetup {
                    // 如果当前 actionId 不在列表中，设为第一项
                    let existsInList = actionStore.actions.contains { $0.id == flowAddRequestDto.actionId }
                    if !existsInList, let firstAction = actionStore.actions.first {
                        flowAddRequestDto.actionId = firstAction.id
                    }
                }
            }
            .onChange(of: accountStore.accountResponseDtoList.count) { _ in
                if needsInitialSetup {
                    // 如果当前 accountId 不在列表中，设为第一项
                    let existsInList = accountStore.accountResponseDtoList.contains { $0.id == flowAddRequestDto.accountId }
                    if !existsInList,
                       let firstAccount = accountStore.accountResponseDtoList.first,
                       let accountId = firstAccount.id {
                        flowAddRequestDto.accountId = accountId
                    }
                }
            }
            .onChange(of: typeStore.typeListResponseDtoList.count) { _ in
                if needsInitialSetup {
                    // 如果当前 typeId 不在列表中，设为第一项
                    let existsInList = typeStore.typeListResponseDtoList.contains { $0.id == flowAddRequestDto.typeId }
                    if !existsInList, let firstType = typeStore.typeListResponseDtoList.first {
                        flowAddRequestDto.typeId = firstType.id
                    }
                }
            }
        }
    }
    
    // 设置初始值为各列表的第一项（如果当前值不在列表中则设置）
    private func setupInitialValues() {
        // 如果当前 actionId 不在列表中，设为第一项
        let actionExists = actionStore.actions.contains { $0.id == flowAddRequestDto.actionId }
        if !actionExists, let firstAction = actionStore.actions.first {
            flowAddRequestDto.actionId = firstAction.id
        }
        
        // 如果当前 accountId 不在列表中，设为第一项
        let accountExists = accountStore.accountResponseDtoList.contains { $0.id == flowAddRequestDto.accountId }
        if !accountExists,
           let firstAccount = accountStore.accountResponseDtoList.first,
           let accountId = firstAccount.id {
            flowAddRequestDto.accountId = accountId
        }
        
        // 如果当前 typeId 不在列表中，设为第一项
        let typeExists = typeStore.typeListResponseDtoList.contains { $0.id == flowAddRequestDto.typeId }
        if !typeExists, let firstType = typeStore.typeListResponseDtoList.first {
            flowAddRequestDto.typeId = firstType.id
        }
    }
}

struct AddBillView_Previews: PreviewProvider {
    static var previews: some View {
        AddFlowView(completion: {newFlowAddRequestDto in print(newFlowAddRequestDto)})
    }
}
