//
//  TypeView.swift
//  EasyAccounts
//
//  Created by 沈俊杰 on 2025/2/11.
//

import SwiftUI

struct TypeView: View {
    var typeListResponseDto: TypeListResponseDto
    
    var body: some View {
        HStack{
            VStack(alignment: .leading) {
                Text(typeListResponseDto.tname)
                    .font(.subheadline)
                    .foregroundColor(.blackDarkMode)
            }
            
            Spacer()
            
            // 一个圆形的银行logo
            Image(systemName: "cart.fill")
                .font(.title3)
                .foregroundColor(.accentColor) // 设置图标颜色，根据需要调整
                .frame(width: 40, height: 40) // 设置圆形 logo 的大小
                .clipShape(Circle()) // 裁剪为圆形
                .overlay(Circle().stroke(Color.gray, lineWidth: 1))

            // TODO 考虑自定义emoji
//            Text("🛍️")
//                .padding(8)
//                .background {Color.indigo.opacity(0.3)}
//                .clipShape(Circle())
        }
    }
}

#Preview {
    TypeView(typeListResponseDto: TypeListResponseDto(id: 1, parent: -1, childrenTypes: [], disable: false, hasChild: false, archive:false, action: nil, tname: "测试"))
}
