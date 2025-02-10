//
//  AddFlowView.swift
//  EasyAccounts
//  记一笔，跳转到本页面
//  Created by 沈俊杰 on 2025/2/8.
//

import SwiftUI

struct AddFlowView: View {
    // 属性已经设置默认值了，就不用实例化时传递了
    @State var flowAddRequestDto: FlowAddRequestDto = .init(money: "", fDate: "", createDate: "", actionId: 16, accountId: 47, accountToId: 0, typeId: 93, isCollect: false, note: "")
    
    @Environment(\.dismiss) private var dismiss
    
    // Date 类型转换为 String
    @State private var selectedDate = Date()
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"  // 指定日期格式
        return formatter
    }()
    
    let completion: (FlowAddRequestDto) -> Void
    
    @StateObject var actionStore = ActionStore()
    @StateObject var accountStore = AccountStore()
    
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
                        Text(action.hName).tag(action.id)
                    }
                }
                .pickerStyle(DefaultPickerStyle())
                
                Picker("选择账户", selection: $flowAddRequestDto.accountId) {
                    ForEach(accountStore.accountResponseDtoList, id: \.id) { account in
                        Text(account.name).tag(account.id)
                    }
                }
                .pickerStyle(DefaultPickerStyle())
                
                // TODO 查询到所有账单分类
                Picker("账单分类", selection: $flowAddRequestDto.typeId) {
                    Text("购物").tag(93)
                }
                .pickerStyle(DefaultPickerStyle())
                
                
                DatePicker("账单日期", selection: $selectedDate, displayedComponents: .date)
                    .onChange(of: selectedDate) { newDate, _ in
                        selectedDate = newDate
                        flowAddRequestDto.fDate = dateFormatter.string(from: newDate)
                    }
                
                Toggle("是否收藏", isOn: $flowAddRequestDto.isCollect)
                
                HStack{
                    Text("备注")
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
                        // 提交逻辑：将封装好的flowAddRequestDto传递给父组件DetailView
                        dismiss()
                        completion(flowAddRequestDto)
                        
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    Spacer()
                }
            }
            .navigationTitle("新增账单")
        }
    }
}

struct AddBillView_Previews: PreviewProvider {
    static var previews: some View {
        AddFlowView(completion: {newFlowAddRequestDto in print(newFlowAddRequestDto)})
    }
}
