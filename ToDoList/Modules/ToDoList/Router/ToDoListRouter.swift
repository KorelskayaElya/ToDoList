//
//  ToDoListRouter.swift
//  ToDoList
//
//  Created by Эля Корельская on 04.08.2025.
//

import UIKit

protocol ToDoListRouterProtocol {
    func navigateToTaskDetail(task: TaskModel)
}

final class ToDoListRouter: ToDoListRouterProtocol {

    // MARK: - Properties

    weak var viewController: UIViewController?

    // MARK: - Functions

    /// Открывает экран детализации задачи
    /// Создаёт экземпляр `ToDoDetailsViewController` с переданной задачей,
    /// настраивает обработчик обновления задачи и выполняет переход по `UINavigationController`
    ///
    /// - Parameter task: Экземпляр `TaskModel`, данные которого будут отображены и редактироваться
    ///   на экране детализации
    func navigateToTaskDetail(task: TaskModel) {
        let detailVC = ToDoDetailsViewController(task: task)
        detailVC.onUpdateTask = { [weak self] updated in
            if let listVC = self?.viewController as? ToDoListViewController {
                listVC.presenter?.updateTask(updated)
            }
        }
        viewController?.navigationController?.pushViewController(detailVC, animated: true)
    }
}

