//
//  StackView+Extension.swift
//  ToDoList
//
//  Created by Эля Корельская on 05.08.2025.
//

import UIKit

extension UIStackView {
    /// Создаёт вертикальный `UIStackView` с заданными представлениями
    ///
    /// - Parameters:
    ///   - arrangedSubviews: Массив `UIView`, которые будут добавлены как arranged subviews
    /// - Returns: Вертикальный `UIStackView` с отступом 4pt между элементами,
    ///   выравниванием по leading и распределением `.fill`
    static func verticalStack(arrangedSubviews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    /// Создаёт вертикальный `UIStackView` из переданных представлений
    ///
    /// - Parameter views: Массив `UIView`
    /// - Returns: Вертикальный `UIStackView` с базовой конфигурацией
    static func buildVerticalViews(views: [UIView]) -> UIStackView {
        let verticalStack = UIStackView.verticalStack(
            arrangedSubviews: views
        )
        return verticalStack
    }
}
