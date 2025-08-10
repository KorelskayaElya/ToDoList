//
//  String+Extension.swift
//  ToDoList
//
//  Created by Эля Корельская on 08.08.2025.
//

import UIKit
/// локализацет строку
extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
