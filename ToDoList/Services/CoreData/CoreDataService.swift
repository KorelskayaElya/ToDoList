//
//  ToDoStorageService.swift
//  ToDoList
//
//  Created by Эля Корельская on 04.08.2025.
//

import CoreData
import UIKit

final class CoreDataService {

    // MARK: - Properties

    private let context: NSManagedObjectContext

    // MARK: - Init

    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }

    static let shared = CoreDataService()

    // MARK: - Functions

    /// Сохранение задачи (создание или обновление)
    /// - Parameter task: `TaskModel`
    func save(task: TaskModel) {
        guard let id = task.id else { return }

        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)

        if let result = try? context.fetch(request), let entity = result.first {
            entity.title = task.title
            entity.desc = task.description
            entity.createdAt = task.createdAt
            entity.isCompleted = task.isCompleted ?? false
        } else {
            let entity = TaskEntity(context: context)
            entity.id = Int32(id)
            entity.title = task.title
            entity.desc = task.description
            entity.createdAt = task.createdAt
            entity.isCompleted = task.isCompleted ?? false
        }
        CoreDataStack.shared.saveContext()
    }

    /// Загрузка всех задач
    /// - Returns: массив `TaskModel`
    func fetchTasks() -> [TaskModel] {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        do {
            let entities = try context.fetch(request)
            return entities.map { TaskModel(
                id: Int($0.id),
                title: $0.title ?? "",
                description: $0.desc ?? "",
                createdAt: $0.createdAt ?? Date(),
                isCompleted: $0.isCompleted
            )}
        } catch {
            return []
        }
    }

    /// Удаление задачи
    /// - Parameter task: `TaskModel`
    func delete(task: TaskModel) {
        guard let taskId = task.id else { return }

        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", taskId)

        if let result = try? context.fetch(request), let objectToDelete = result.first {
            context.delete(objectToDelete)
            CoreDataStack.shared.saveContext()
        }
    }

    /// Обновление задачи
    /// - Parameter task: `TaskModel`
    func update(task: TaskModel) {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", task.id ?? 0)

        if let entity = try? context.fetch(request).first {
            entity.title = task.title
            entity.desc = task.description
            entity.createdAt = task.createdAt
            entity.isCompleted = task.isCompleted ?? false
            CoreDataStack.shared.saveContext()
        }
    }
}
