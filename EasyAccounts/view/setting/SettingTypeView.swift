//
//  EditTypeView.swift
//  EasyAccounts
//
//  Created by 沈俊杰 on 2025/2/10.
//

import SwiftUI

struct SettingTypeView: View {
    var typeStore: TypeStore
    
    @State var addNewType: TypeSingleDto?
    
    var body: some View {
        NavigationView {
            TypeList(
                typeList: typeStore.typeListResponseDtoList,
                typeStore: typeStore
            )
            .padding(15)
            .navigationTitle("分类")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(action: {
                    // 添加一个新分类的操作
                    addNewType = TypeSingleDto(id: nil, tname: "", archive: false)
                }) {
                    Text("添加分类")
                }
            }
            // 添加分类
            .sheet(item: $addNewType, content: { type in
                TypeEditView(
                    type: type,
                    completion: { newType in
//                        print(newType)
                         typeStore.addType(typeSingleDto: newType)
                    }
                )
            })

        }
    }
}

#Preview {
    SettingTypeView(typeStore: TypeStore())
}
