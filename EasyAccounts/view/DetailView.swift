//
//  Flow.swift
//  EasyAccounts
//  流水页，我取名为：DetailView，区别于FlowView
//  FlowView是单条Flow展示的页面！
//  Created by 沈俊杰 on 2025/2/2.
//

import SwiftUI
import ImagePickerView

struct AlertMessage: Identifiable {
    let id = UUID()
    let message: String
}

struct DetailView: View {
    @StateObject var detailStore = DetailStore()
    @StateObject var accountStore = AccountStore()
    @StateObject var actionStore = ActionStore()
    @StateObject var typeStore = TypeStore()
    
    @State private var date = Date() // 默认日期为当前日期
    @State private var showingDatePicker = false
    @State private var isShowingAddFlowView: Bool = false
    
    @State private var selectedDate = Date()
    {
        didSet { detailStore.updateYearAndMonth(selectDate: selectedDate) }
    }
    
    @State private var year: Int
    @State private var month: Int
    
    @State var image: UIImage?
    @State var showImagePicker: Bool = false
    
    // AI识别，等待框
    @State private var responseMessage = ""
    @State var isLoading: Bool = false
//    @State private var showAlert = false
    @State private var showProcessingAlert = false
    @State private var showCompletionAlert = false
    
    @State private var taskId: String = ""
    
    @State private var alertMessage: AlertMessage?
    
    // 初始化为系统当前年月
    init() {
        let currentDate = Date()
        let calendar = Calendar.current
        self._year = State(initialValue: calendar.component(.year, from: currentDate))
        self._month = State(initialValue: calendar.component(.month, from: currentDate))
    }
    
    // 月份选择器，计算月份加减的方法
    private func updateSelectedDate() {
        if let newDate = Calendar.current.date(from: DateComponents(year: year, month: month)) {
            selectedDate = newDate
        }
    }
    
    private func incrementMonth() {
        month += 1
        if month > 12 {
            month = 1
            year += 1
        }
        updateSelectedDate()
    }
    
    private func decrementMonth() {
        month -= 1
        if month < 1 {
            month = 12
            year -= 1
        }
        updateSelectedDate()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // FlowList
                FlowList(flows: detailStore.flowListDto.flows, detailStore: detailStore,
                         accountStore: accountStore,
                         actionStore: actionStore,
                         typeStore: typeStore
                )
                .navigationTitle("\(month)月流水")
                .navigationBarItems(
                    leading:
                        Button(action: {
                        // 在这里添加生成报表的逻辑
                        print("报表已生成")
                            detailStore.makeExcel{success, message in
                                self.responseMessage = "✅报表生成成功，已发邮件"
                                self.showCompletionAlert = true
                            }
                        }) {Text("生成报表")},
                    trailing: Menu {
                        // 手动录入：记一笔
                        Button(action: {
                            isShowingAddFlowView.toggle()
                        }, label : {
                            Text("记一笔")
                        })

                        // 上传图片：AI识别
                        Button(action: {
                            // 弹出图片选择器
                            showImagePicker.toggle()
                        }, label : {
                            Text("AI识别")
                        })
                        } label: {
                            Text("记一笔")
    //                        HStack{
    //                            Image(systemName: "plus.circle")
    //                                .font(.system(size: 18))
    //                            Text("记一笔")
    //                        }
                        }
                )
                // 弹出：修改Flow详情页
                .sheet(isPresented: $isShowingAddFlowView, content: {
                    AddFlowView(completion: {newFlowAddRequestDto in detailStore.addFlow(flowAddRequestDto: newFlowAddRequestDto)})
                })
                // 弹出：图片选择页
//                .sheet(isPresented: $showImagePicker, content: {
//                    ImagePickerView(sourceType: .photoLibrary){
//                        image in
//                        self.image = image
//                        self.isLoading = true
//                        self.responseMessage = "🤖️处理中..."
//                        self.showProcessingAlert = true
//                        detailStore.uploadImageAndGetTaskId(flowImg: image) { taskId in
//                            DispatchQueue.main.async {
//                                self.taskId = taskId
//                                self.isLoading = false
//                                self.showProcessingAlert = false
//                                self.responseMessage = "任务ID：\(taskId)"
//                                self.showCompletionAlert = true
//                            }
//                        }
//                    }
//                })
                .sheet(isPresented: $showImagePicker) {
                    ImagePickerView(sourceType: .photoLibrary) { image in
                        self.image = image
                        self.isLoading = true
                        alertMessage = AlertMessage(message: "🤖️处理中...")

                        detailStore.uploadImageAndGetTaskId(flowImg: image) { taskId in
                            DispatchQueue.main.async {
                                self.taskId = taskId
                                self.isLoading = false
                                alertMessage = AlertMessage(message: "任务ID：\(taskId)")
                            }
                        }
                    }
                }
                // 这里如果注释掉，可以让FlowList的删除有提示
                // 如果这里保留，FlowList的删除就会失效
                // 因为isPresented只能在父子之间的一处使用。
//                .alert(isPresented: $showCompletionAlert) {
//                    Alert(title: Text("状态"), message: Text(responseMessage), dismissButton: .default(Text("好")) {
//                        // Reset image and state when alert is dismissed
//                        self.image = nil
//                    })
//                }
//                .alert(isPresented: $showReportAlert) {
//                    Alert(
//                        title: Text("报表导出"),
//                        message: Text(reportMessage),
//                        dismissButton: .default(Text("好"))
//                    )
//                }
                .refreshable {
                    isLoading = true
                    detailStore.getAnalysisResult(taskId: taskId) { success, message in
                        DispatchQueue.main.async {
                            if success {
                                // 已完成，触发刷新
                                detailStore.loadData()
                            } else {
                                // 未完成或失败，提示用户
//                                self.responseMessage = message
//                                self.showCompletionAlert = true
                                alertMessage = AlertMessage(message: message)
                            }
                            self.isLoading = false
                        }
                    }
                }
            }
        }
        .alert(item: $alertMessage) { alert in
            Alert(title: Text("提示"), message: Text(alert.message), dismissButton: .default(Text("好")))
        }
        
        //AI识别过程中，顶层的Alert弹窗
        .overlay(
            Group {
                if showProcessingAlert {
                    VStack {
                        if isLoading {
                            ProgressView(responseMessage)
                                .foregroundColor(.blackDarkMode)
                        }
                    }
                    .padding()
                    .background(Color.whiteDarkMode)
                    .cornerRadius(10)
                    .transition(.opacity.animation(.easeInOut))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            if self.isLoading {
                                self.showProcessingAlert = false
                            }
                        }
                    }
                }
            }
        )
    }
}

#Preview {
    DetailView()
}
