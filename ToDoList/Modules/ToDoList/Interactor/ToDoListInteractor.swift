//
//  ToDoListInteractor.swift
//  ToDoList
//
//  Created by Эля Корельская on 04.08.2025.
//

import UIKit

protocol ToDoListInteractorProtocol: AnyObject {
    /// загрузка задач
    func fetchTasks()
    /// Выполняет поиск задач по текстовому запросу
    /// - Parameter query: Строка поиска
    func searchTasks(query: String)
    /// Добавляет новую задачу в локальное хранилище и обновляет список
    /// - Parameter task: Новая задача
    func addTask(title: String, description: String)
    func deleteTask(_ task: TaskModel)
    func updateTask(_ task: TaskModel)
}

/// Класс Interactor, реализующий бизнес-логику для экрана списка задач
final class ToDoListInteractor: ToDoListInteractorProtocol {

    // MARK: - Properties

    weak var presenter: ToDoListPresenterProtocol?
    private var allTasks: [TaskModel] = []

    // MARK: - Function

    /// Генерирует уникальный идентификатор для новой задачи
    /// Идентификатор определяется как максимальный из существующих `id` + 1
    ///
    /// - Returns: Новый уникальный идентификатор задачи
    private func nextUniqueId() -> Int {
        let existing = allTasks.compactMap { $0.id }
        return (existing.max() ?? 0) + 1
    }


    /// Загружает список задач из локального хранилища или сети
    /// Если локальных задач нет — выполняет сетевой запрос, сохраняет полученные задачи в Core Data
    /// и передаёт их презентеру. В случае ошибки при загрузке из сети — сообщает презентеру об ошибке
    func fetchTasks() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            let localTasks = CoreDataService.shared.fetchTasks()

            if localTasks.isEmpty {
                NetworkService.shared.fetchTodos(
                    completion: { tasks in
                        DispatchQueue.main.async {
                            tasks.forEach { CoreDataService.shared.save(task: $0) }
                            self.allTasks = CoreDataService.shared.fetchTasks()
                            self.presenter?.didFetchTasks(self.allTasks)
                        }
                    },
                    failure: { error in
                        DispatchQueue.main.async {
                            self.presenter?.didFailToFetchTasks(error: "Ошибка загрузки из сети: \(error.localizedDescription)")
                            self.presenter?.didFetchTasks([])
                        }
                    }
                )
            } else {
                DispatchQueue.main.async {
                    self.allTasks = localTasks
                    self.presenter?.didFetchTasks(localTasks)
                }
            }
        }
    }

    /// Выполняет поиск задач по запросу
    /// Если строка поиска пуста — возвращает полный список
    /// Поиск производится по заголовку и описанию задачи
    ///
    /// - Parameter query: Текст поискового запроса
    func searchTasks(query: String) {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty {
            presenter?.didFetchTasks(allTasks)
            return
        }
        let filtered = allTasks.filter {
            ($0.title?.lowercased().contains(q) ?? false) ||
            ($0.description?.lowercased().contains(q) ?? false)
        }
        presenter?.didFetchTasks(filtered)
    }

    /// Добавляет новую задачу в локальное хранилище
    /// После сохранения обновляет список задач из Core Data и передаёт его презентеру
    ///
    /// - Parameters:
    ///   - title: Заголовок задачи
    ///   - description: Описание задачи
    func addTask(title: String, description: String) {
        let newTask = TaskModel(
            id: nextUniqueId(),
            title: title,
            description: description,
            createdAt: Date(),
            isCompleted: false
        )
        CoreDataService.shared.save(task: newTask)
        reloadFromCoreData()
    }

    /// Удаляет указанную задачу из локального хранилища
    /// После удаления обновляет список задач из Core Data и передаёт его презентеру
    ///
    /// - Parameter task: Модель задачи для удаления
    func deleteTask(_ task: TaskModel) {
        CoreDataService.shared.delete(task: task)
        reloadFromCoreData()
    }

    /// Обновляет данные указанной задачи в локальном хранилище
    /// После обновления перечитывает список задач и передаёт его презентеру
    ///
    /// - Parameter task: Модель задачи с обновлёнными данными
    func updateTask(_ task: TaskModel) {
        CoreDataService.shared.update(task: task)
        reloadFromCoreData()
    }

    /// Перечитывает список задач из Core Data, сортирует их по дате создания (от новых к старым)
    /// и передаёт результат презентеру
    private func reloadFromCoreData() {
        allTasks = CoreDataService.shared.fetchTasks().sorted {
            ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast)
        }
        presenter?.didFetchTasks(allTasks)
    }
}
