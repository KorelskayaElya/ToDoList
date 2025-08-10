//
//  ToDoListPresenter.swift
//  ToDoList
//
//  Created by Эля Корельская on 04.08.2025.
//

import UIKit

protocol ToDoListPresenterProtocol: AnyObject {
    func fetchTasks()
    func didFetchTasks(_ tasks: [TaskModel])
    func searchTasks(query: String)
    func addTask(title: String, description: String)
    func updateTask(_ task: TaskModel)
    func didFailToFetchTasks(error: String)
    func didSelectTask(_ task: TaskModel)
    func deleteTask(_ task: TaskModel)
}

/// Класс Presenter, обрабатывающий данные между View и Interactor
final class ToDoListPresenter: ToDoListPresenterProtocol {

    // MARK: - Properties

    weak var view: ToDoListViewProtocol?
    var interactor: ToDoListInteractorProtocol?
    var router: ToDoListRouterProtocol?

    // MARK: - Functions

    /// Инициирует загрузку задач через Interactor
    func fetchTasks() {
        interactor?.fetchTasks()
    }

    /// Получает задачи от Interactor и передаёт их в View
    /// - Parameter tasks: Список задач
    func didFetchTasks(_ tasks: [TaskModel]) {
        view?.displayTasks(tasks)
    }

    /// Инициирует поиск задач по текстовому запросу
    /// - Parameter query: Поисковая строка
    func searchTasks(query: String) {
        interactor?.searchTasks(query: query)
    }

    /// Создаёт новую задачу и передаёт её в Interactor для сохранения
    /// - Parameters:
    ///   - id: Идентификатор
    ///   - title: Заголовок
    ///   - description: Описание
    func addTask(title: String, description: String) {
        interactor?.addTask(title: title, description: description)
    }

    /// Передаёт сообщение об ошибке во View для отображения алерта
    /// - Parameter error: Текст ошибки
    func didFailToFetchTasks(error: String) {
        view?.showError(message: error)
    }

    /// Обрабатывает выбор задачи и запускает навигацию на экран деталей через Router
    /// - Parameter task: Список задач
    func didSelectTask(_ task: TaskModel) {
        router?.navigateToTaskDetail(task: task)
    }

    /// Обновляет существующую задачу
    /// Передаёт изменённую модель задачи в интерактор для сохранения
    ///
    /// - Parameter task: Обновлённая модель `TaskModel`, которая должна быть сохранена
    func updateTask(_ task: TaskModel) {
        interactor?.updateTask(task)
    }

    /// Удаляет задачу
    /// Передаёт модель задачи в интерактор для удаления
    ///
    /// - Parameter task: Модель `TaskModel`, которую требуется удалить
    func deleteTask(_ task: TaskModel) {
        interactor?.deleteTask(task)
    }
}


