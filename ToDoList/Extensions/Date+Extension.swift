//
//  Date+Extension.swift
//  ToDoList
//
//  Created by Эля Корельская on 05.08.2025.
//

import Foundation

extension Date {
    /// Преобразует дату в короткий строковый формат  `dd/MM/yy`
    func toShortString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: self)
    }
}
