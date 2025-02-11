//
//  TypeList.swift
//  EasyAccounts
//
//  Created by 沈俊杰 on 2025/2/11.
//

import SwiftUI

struct TypeList: View {
    var typeList: [TypeListResponseDto]
    
    @State var editingType: TypeSingleDto?
    
    @StateObject var typeStore = TypeStore()
    
    var body: some View {
        List {
            ForEach(typeList) {type in
                TypeView(typeListResponseDto: type)
                    .swipeActions(edge: .trailing){
                        Button("删除",role: .destructive){
                            // 实现删除这一条Type的逻辑
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
        .sheet(item: $editingType, content: {type in
            TypeEditView(
                type: type,
                completion: { newType in
//                    print(newType)
                    typeStore.updateType(typeSingleDto: newType)
                }
            )
        })
    }
}

#Preview {
    TypeList(typeList: [
        TypeListResponseDto(id: 1, parent: -1, childrenTypes: [], disable: false, hasChild: false, archive:false, action: nil, tname: "测试"),
        TypeListResponseDto(id: 2, parent: -1, childrenTypes: [], disable: false, hasChild: false, archive:false, action: nil, tname: "测试2")])
}
