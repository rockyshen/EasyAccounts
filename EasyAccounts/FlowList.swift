//
//  FlowList.swift
//  EasyAccounts
//  流水列表的视图
//  Created by 沈俊杰 on 2025/2/4.
//

import SwiftUI

struct FlowList: View {
    var flows: [FlowListSingleDto]
    
    var detailStore: DetailStore
    
    var accountStore: AccountStore
    
    var actionStore: ActionStore
    
    var typeStore: TypeStore
    
    // 编辑时，选中的对象
    @State var editingFlow: FlowListSingleDto?
    
    // 删除时，选中的对象
    @State private var selectedFlow: FlowListSingleDto?
    @State private var showingDeleteAlert = false
    
    var body: some View {
        List {
            ForEach(flows) {flow in
                FlowView(flow: flow)
                    .swipeActions(edge: .trailing){
                        Button("删除",role: .destructive){
                            // TODO 实现删除这一条Flow的逻辑
                            showingDeleteAlert.toggle()
                            selectedFlow = flow
                        }
                    }
                    .swipeActions(edge: .leading){
                        Button("编辑"){
                            // TODO 实现编辑修改这一条Flow的逻辑
                            editingFlow = flow
                        }.tint(.blue)
                    }
            }
        }
        .listStyle(PlainListStyle())
        .sheet(item: $editingFlow, content: {flow in
            // FlowListSingleDto ==>  FlowAddRequestDto
            // 还要FlowListSingleDto里的id
            let newFlowAddRequestDto = FlowAddRequestDto(
                    money: flow.money,
                    fDate: flow.fdate,
                    createDate: "",      // 默认为空
                    actionId: actionStore.getActionIdByhame(hName: flow.hname) ?? 0 ,
                    accountId: accountStore.getAccountIdByName(accountName: flow.aname) ?? 0,
                    accountToId: 0,      // 内部转账id,默认是0
                    typeId: typeStore.getTypeIdByName(typeName: flow.tname) ?? 0,
                    isCollect: flow.collect,              // 直接使用
                    note: flow.note                       // 直接使用
                )
            
            // 编辑Flow的页面，复用AddFlowView
            AddFlowView(flowAddRequestDto: newFlowAddRequestDto) { newFlowAddRequestDto in
                detailStore.updateFlow(flowId: flow.id, flowAddRequestDto: newFlowAddRequestDto)
            }
        })
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("确认删除"),
                message: Text("您确定要删除这条流水吗？"),
                primaryButton: .destructive(Text("删除")) {
                    // 调用DetailStore的delete方法
                    showingDeleteAlert = false
                    detailStore.deleteFlow(flowId: selectedFlow!.id)
                },
                secondaryButton: .cancel() {
                    showingDeleteAlert = false
                }
            )
        }
    }
}


//#Preview {
//    FlowList(flowStore: FlowStore())
//}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FlowList(flows: [
            FlowListSingleDto(id: 1, money: "10", exempt: false, collect: true, handle: 1, note: "买了个包子", toAName: "To A Name", aname: "测试账户", tname: "购物", hname: "支出", fdate: "2022-05-01"),
            FlowListSingleDto(id: 2, money: "28", exempt: true, collect: false, handle: 2, note: "买了奶茶", toAName: nil, aname: "Swift Bank", tname: "餐饮", hname: "支出", fdate: "2022-05-02")
        ],detailStore: DetailStore(),accountStore: AccountStore(), actionStore: ActionStore(), typeStore: TypeStore())
        .previewLayout(.sizeThatFits)
    }
}
