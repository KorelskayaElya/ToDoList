//
//  AlertHelper.swift
//  ToDoList
//
//  Created by Эля Корельская on 05.08.2025.
//

import UIKit

enum AlertHelper {
    /// Создаёт и настраивает алерт
    ///
    /// - Parameters:
    ///   - title: Заголовок окна
    ///   - message: Текст сообщения под заголовком
    ///   - actions: Массив действий (`UIAlertAction`), которые будут добавлены к алерту
    /// - Returns: Готовый к показу `UIAlertController` c `preferredStyle = .alert`
    static func buildAlertWithActions(
        title: String,
        message: String,
        actions: [UIAlertAction]
    ) -> UIAlertController {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        for action in actions {
            alertController.addAction(action)
        }

        return alertController
    }
}

