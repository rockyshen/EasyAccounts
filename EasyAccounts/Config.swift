//
//  Config.swift
//  EasyAccounts
//
//  Created by 沈俊杰 on 2025/7/4.
//

import Foundation
import SwiftUI

// Config.swift
struct APIConfig {
    // 开发环境
//    static let baseURL = "http://localhost:8085"
    
    // 后端服务easy_account_server，运行在腾讯云主机118.25.46.207
    static let baseURL = "http://118.25.46.207:8085"
    
    // 如需切换服务器地址，只需修改上面的 baseURL
}

// MARK: - 主题管理器
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @AppStorage("darkModeEnabled") var isDarkMode: Bool = true {
        didSet {
            objectWillChange.send()
        }
    }
    
    private init() {}
}

// MARK: - 主题颜色（支持深色/浅色切换）
extension Color {
    // 获取当前主题状态
    private static var isDark: Bool {
        ThemeManager.shared.isDarkMode
    }
    
    // 背景色
    static var themeBg: Color {
        isDark ? Color(hex: "1A1A1A") : Color(hex: "F5F5F7")
    }
    static var themeCardBg: Color {
        isDark ? Color(hex: "0A0A0A") : Color(hex: "FFFFFF")
    }
    static var themeNavBg: Color {
        isDark ? Color(hex: "000000", opacity: 0.9) : Color(hex: "FFFFFF", opacity: 0.95)
    }
    
    // 主题强调色（深浅模式保持一致）
    static let themeAccent = Color(hex: "05DF72")       // 亮绿色主题色
    static let themeBlue = Color(hex: "51A2FF")         // AI标签蓝色
    
    // 文本颜色
    static var themeTextPrimary: Color {
        isDark ? Color(hex: "F3F4F6") : Color(hex: "1A1A1A")
    }
    static var themeTextSecondary: Color {
        isDark ? Color(hex: "6A7282") : Color(hex: "6B7280")
    }
    static var themeTextMuted: Color {
        isDark ? Color(hex: "99A1AF") : Color(hex: "9CA3AF")
    }
    static var themeTextTitle: Color {
        isDark ? Color(hex: "D1D5DC") : Color(hex: "374151")
    }
    
    // 功能色（深浅模式保持一致）
    static let themeIncome = Color(hex: "05DF72")       // 收入绿色
    static let themeExpense = Color(hex: "FF6467")      // 支出红色
    
    // 边框色
    static var themeBorder: Color {
        isDark ? Color(hex: "4A5565") : Color(hex: "D1D5DB")
    }
    static var themeBorderLight: Color {
        isDark ? Color(hex: "6A7282", opacity: 0.3) : Color(hex: "E5E7EB", opacity: 0.8)
    }
    
    // 分类标签颜色（深浅模式保持一致）
    static let themeTagPurple = Color(hex: "C27AFF")
    static let themeTagYellow = Color(hex: "FDC700")
    static let themeTagCyan = Color(hex: "06B6D4")
    static let themeTagPink = Color(hex: "EC4899")
    
    // 从十六进制创建颜色
    init(hex: String, opacity: Double = 1.0) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: opacity
        )
    }
}
