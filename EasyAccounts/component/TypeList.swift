//
//  TypeList.swift
//  EasyAccounts
//
//  Created by 沈俊杰 on 2025/2/11.
//

import SwiftUI

struct TypeList: View {
    @State var editingType: TypeSingleDto?
    
    // 使用 @ObservedObject 确保数据更新时视图自动刷新
    @ObservedObject var typeStore: TypeStore
    
    // 待删除的Type
    @State private var showingDeleteAlert = false
    @State private var selectedType: TypeSingleDto?
    
    var body: some View {
        List {
            ForEach(typeStore.typeListResponseDtoList) {type in
                TypeView(typeListResponseDto: type)
                    .swipeActions(edge: .trailing){
                        Button("删除",role: .destructive){
                            // 实现删除这一条Type的逻辑
                            // 必须弹窗确认
                            // 将typeListResponseDto 转为 typeSingleDto
                            showingDeleteAlert.toggle()
                            selectedType = TypeSingleDto(id: type.id, tname: type.tname, archive: type.archive, actionId: type.action?.id)
                        }
                    }
                    .swipeActions(edge: .leading){
                        Button("编辑"){
                            // 实现编辑修改这一条Type的逻辑
                            // 将typeListResponseDto 转为 typeSingleDto
                            editingType = TypeSingleDto(id: type.id, tname: type.tname, archive: type.archive, actionId: type.action?.id)
                        }.tint(.blue)
                    }
            }
        }
        .listStyle(PlainListStyle())
        .refreshable {
            typeStore.loadTypes()
        }
        .sheet(item: $editingType, content: {type in
            TypeEditView(
                type: type,
                completion: { newType in
//                    print(newType)
                    typeStore.updateType(typeSingleDto: newType)
                }
            )
        })
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("确认删除"),
                message: Text("您确定要删除这个账户吗？"),
                primaryButton: .destructive(Text("删除")) {
                    typeStore.deleteType(typeSingleDto: selectedType!)
                    showingDeleteAlert = false
                },
                secondaryButton: .cancel() {
                    showingDeleteAlert = false
                }
            )
        }
        
    }
}

#Preview {
    TypeList(typeStore: TypeStore())
}
