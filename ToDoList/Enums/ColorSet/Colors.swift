//
//  Colors.swift
//  ToDoList
//
//  Created by Эля Корельская on 04.08.2025.
//

import UIKit

/// Набор используемых в приложении цветов
enum Colors {
    private static let defaultColor: UIColor = .cyan

    // MARK: - Текстовые цвета

    enum Text {
        static let black = UIColor(named: "SecondaryTextColor") ?? defaultColor
        static let gray = UIColor(named: "PrimaryTextColor") ?? defaultColor
        static let red = UIColor(named: "DeleteTextColor") ?? defaultColor
        static let yellow = UIColor(named: "ThirdTextColor") ?? defaultColor
    }

    // MARK: - Цвета фона

    enum Background {
        static let gray = UIColor(named: "SecondaryBackgroundColor") ?? defaultColor
        static let black = UIColor(named: "PrimaryBackgroundColor") ??
        defaultColor
    }
}
