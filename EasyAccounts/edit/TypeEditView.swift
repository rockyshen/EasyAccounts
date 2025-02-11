//
//  TypeEditView.swift
//  EasyAccounts
//  编辑“分类页”的视图
//  Created by 沈俊杰 on 2025/2/11.
//

import SwiftUI

struct TypeEditView: View {
    @State var type: TypeSingleDto
    
    let completion: (TypeSingleDto) -> Void
    
    @Environment(\.dismiss) private var dismiss   // 关闭sheet弹出页面
    
    var body: some View {
        NavigationStack {
            List(){
                Group{    // 统一给它们添加padding的效果
                    TextField("分类名称", text: $type.tname)
//                    TextField("父级分类", text: Binding(
//                        get: {
//                            if let parent = self.type.parent {
//                                return String(parent)
//                            } else {
//                                return "" // 如果 parent 为 nil，显示为空字符串
//                            }
//                        },
//                        set: {
//                            // 在用户输入后，尝试将其转换回 Int
//                            if let value = Int($0) {
//                                self.type.parent = value
//                            } else {
//                                self.type.parent = nil // 如果无法转换，将其视为 nil
//                            }
//                        }
//                    ))
//                    TextField("绑定收支", text: $type.action.wrappedValue?.hName)
                }
                .padding(.vertical,8)
            }
            .navigationTitle("编辑分类")
            .safeAreaInset(edge: .bottom) {
                Button(action: {
                    // 完成按钮的具体逻辑
                    // 1.关闭Edit页面；2、将数据往父目录提交
                    dismiss()
                    completion(type)
                }, label: {
                    HStack(spacing: 12){
                        Text("更新")
                            .padding(.vertical,12)
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth:.infinity, alignment:.center)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                })
                .padding(.horizontal,16)
                .padding(.bottom,8)
            }
        }
    }
}

#Preview {
    TypeEditView(type: TypeSingleDto(id: 1, tname: "测试分类", archive: false, actionId: 1), completion: {type in print(type.tname)})
}
