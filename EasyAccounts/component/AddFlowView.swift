//
//  AddFlowView.swift
//  EasyAccounts
//  记一笔 - 深色科技风格
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
    
    @State var flowAddRequestDto: FlowAddRequestDto
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()
    
    init(flowAddRequestDto: FlowAddRequestDto = .init(
        money: "",
        fDate: Self.dateFormatter.string(from: Date()),
        createDate: Self.dateFormatter.string(from: Date()),
        actionId: 0,
        accountId: 0,
        accountToId: 0,
        typeId: 0,
        isCollect: false,
        note: ""
    ), completion: @escaping (FlowAddRequestDto) -> Void) {
        self._flowAddRequestDto = State(initialValue: flowAddRequestDto)
        self.completion = completion
        
        if !flowAddRequestDto.fDate.isEmpty,
           let date = Self.dateFormatter.date(from: flowAddRequestDto.fDate) {
            self._selectedDate = State(initialValue: date)
        }
        
        self._needsInitialSetup = State(initialValue: flowAddRequestDto.money.isEmpty)
    }
    
    let completion: (FlowAddRequestDto) -> Void
    
    @StateObject var actionStore = ActionStore()
    @StateObject var accountStore = AccountStore()
    @StateObject var typeStore = TypeStore()
    @State private var needsInitialSetup = true
    
    var body: some View {
        NavigationView {
            ZStack {
                // 深色背景
                Color.themeBg.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // MARK: - 账单金额
                        VStack(alignment: .leading, spacing: 8) {
                            Text("AMOUNT")
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(.themeTextSecondary)
                            
                            HStack {
                                Text("¥")
                                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                                    .foregroundColor(.themeAccent)
                                
                                TextField("0.00", text: $flowAddRequestDto.money)
                                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                                    .foregroundColor(.themeTextPrimary)
                                    .keyboardType(.decimalPad)
                                    .textInputAutocapitalization(.none)
                            }
                            .padding(16)
                            .background(Color.themeCardBg)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.themeAccent.opacity(0.5), lineWidth: 1)
                            )
                        }
                        
                        // MARK: - 选择收支
                        FormPickerRow(
                            label: "ACTION",
                            selection: $flowAddRequestDto.actionId,
                            options: actionStore.actions.map { ($0.id, $0.hname) }
                        )
                        
                        // MARK: - 选择账户
                        FormPickerRow(
                            label: "ACCOUNT",
                            selection: $flowAddRequestDto.accountId,
                            options: accountStore.accountResponseDtoList.compactMap {
                                guard let id = $0.id else { return nil }
                                return (id, $0.name)
                            }
                        )
                        
                        // MARK: - 账单分类
                        FormPickerRow(
                            label: "CATEGORY",
                            selection: $flowAddRequestDto.typeId,
                            options: typeStore.typeListResponseDtoList.map { ($0.id, $0.tname) }
                        )
                        
                        // MARK: - 账单日期
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DATE")
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(.themeTextSecondary)
                            
                            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .tint(.themeAccent)
                                .padding(12)
                                .background(Color.themeCardBg)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.themeBorderLight, lineWidth: 1)
                                )
                                .onChange(of: selectedDate) { newDate in
                                    flowAddRequestDto.fDate = Self.dateFormatter.string(from: newDate)
                                }
                        }
                        
                        // MARK: - 是否收藏
                        HStack {
                            Text("FAVORITE")
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(.themeTextSecondary)
                            
                            Spacer()
                            
                            Toggle("", isOn: $flowAddRequestDto.isCollect)
                                .labelsHidden()
                                .tint(.themeAccent)
                        }
                        .padding(16)
                        .background(Color.themeCardBg)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.themeBorderLight, lineWidth: 1)
                        )
                        
                        // MARK: - 备注
                        VStack(alignment: .leading, spacing: 8) {
                            Text("NOTE")
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(.themeTextSecondary)
                            
                            TextField("// Add your note here...", text: $flowAddRequestDto.note, axis: .vertical)
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(.themeTextPrimary)
                                .textInputAutocapitalization(.none)
                                .lineLimit(3...6)
                                .padding(16)
                                .background(Color.themeCardBg)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.themeBorderLight, lineWidth: 1)
                                )
                        }
                        
                        // MARK: - 提交按钮
                        Button(action: submitFlow) {
                            Text("SUBMIT")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.themeAccent)
                                .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("$ new-transaction")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.themeAccent)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.themeTextSecondary)
                    }
                }
            }
            .toolbarBackground(Color.themeBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                if needsInitialSetup {
                    setupInitialValues()
                }
            }
            .onChange(of: actionStore.actions.count) { _ in
                if needsInitialSetup {
                    let existsInList = actionStore.actions.contains { $0.id == flowAddRequestDto.actionId }
                    if !existsInList, let firstAction = actionStore.actions.first {
                        flowAddRequestDto.actionId = firstAction.id
                    }
                }
            }
            .onChange(of: accountStore.accountResponseDtoList.count) { _ in
                if needsInitialSetup {
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
                    let existsInList = typeStore.typeListResponseDtoList.contains { $0.id == flowAddRequestDto.typeId }
                    if !existsInList, let firstType = typeStore.typeListResponseDtoList.first {
                        flowAddRequestDto.typeId = firstType.id
                    }
                }
            }
        }
    }

    private func submitFlow() {
        var submitDto = flowAddRequestDto
        submitDto.fDate = Self.dateFormatter.string(from: selectedDate)
        submitDto.createDate = Self.dateFormatter.string(from: Date())
        submitDto.accountToId = 0
        
        dismiss()
        completion(submitDto)
        print("📝 提交流水: \(submitDto)")
    }
    
    private func setupInitialValues() {
        let actionExists = actionStore.actions.contains { $0.id == flowAddRequestDto.actionId }
        if !actionExists, let firstAction = actionStore.actions.first {
            flowAddRequestDto.actionId = firstAction.id
        }
        
        let accountExists = accountStore.accountResponseDtoList.contains { $0.id == flowAddRequestDto.accountId }
        if !accountExists,
           let firstAccount = accountStore.accountResponseDtoList.first,
           let accountId = firstAccount.id {
            flowAddRequestDto.accountId = accountId
        }
        
        let typeExists = typeStore.typeListResponseDtoList.contains { $0.id == flowAddRequestDto.typeId }
        if !typeExists, let firstType = typeStore.typeListResponseDtoList.first {
            flowAddRequestDto.typeId = firstType.id
        }
    }
}

// MARK: - 表单选择器行组件
struct FormPickerRow: View {
    let label: String
    @Binding var selection: Int
    let options: [(Int, String)]
    
    var selectedOptionName: String {
        options.first { $0.0 == selection }?.1 ?? "Select..."
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.themeTextSecondary)
            
            Menu {
                ForEach(options, id: \.0) { option in
                    Button(action: {
                        selection = option.0
                    }) {
                        HStack {
                            Text(option.1)
                            if selection == option.0 {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selectedOptionName)
                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                        .foregroundColor(.themeAccent)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.themeTextSecondary)
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
    }
}

struct AddBillView_Previews: PreviewProvider {
    static var previews: some View {
        AddFlowView(completion: { newFlowAddRequestDto in print(newFlowAddRequestDto) })
    }
}
