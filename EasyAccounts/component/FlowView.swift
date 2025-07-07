//
//  FlowView.swift
//  EasyAccounts
//  单条流水的视图
//  Created by 沈俊杰 on 2025/2/4.
//

import SwiftUI

struct FlowView: View {
    var flow: FlowListSingleDto
    
    var body: some View {
        HStack{
            VStack(alignment: .leading) {
                Text(flow.fdate)
                    .font(.subheadline)
                    .foregroundColor(Color.blackDarkMode)
                
                Text(flow.tname)
                    .font(.subheadline)
                    .foregroundColor(Color.blackDarkMode)
                
                Text(shortenText(flow.note, to: 20))
                    .font(.footnote)
                    .foregroundColor(Color.blackDarkMode)
            }
            
            Spacer()
            
            HStack{
                VStack(alignment: .trailing){
                    HStack{
                        Text("¥")
                        Text(flow.money)
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                    
                    Text(flow.hname)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(5) // 内边距
                        .background(flow.hname == "支出" ? Color.red : Color.green)
                        .cornerRadius(10) // 圆角
    //                        .padding(.vertical,0.1) // 外边距
                }
            }
            
        }
//        .padding()
        .frame(maxWidth: .infinity)                  // ✅ 撑满整行
        .background(Color.whiteDarkMode)                    // （可选）避免 List 背景影响可见性
        .contentShape(Rectangle())                  // ✅ 手势识别区域扩大
    }
    
    func shortenText(_ text: String, to length: Int) -> String {
        if text.count > length {
            let index = text.index(text.startIndex, offsetBy: length)
            return text[..<index] + "..." // 截断并追加省略号
        }
        return text
    }
}


struct FlowView_Previews: PreviewProvider {
    static var previews: some View {
        FlowView(flow: FlowListSingleDto(id: 1,
                                         money: "100",
                                         exempt: false,
                                         collect: true,
                                         handle: 1,
                                         note: "备注123456789123456",
                                         toAName: "Sample ToAName",
                                         aname: "Sample AName",
                                         tname: "购物",
                                         hname: "支出",
                                         fdate: "2022-07-01"))
    }
}
