//
//  CoreDataStack.swift
//  ToDoList
//
//  Created by Эля Корельская on 04.08.2025.
//

import CoreData
import UIKit

/// Синглтон для управления Core Data стеком.
final class CoreDataStack {

    // MARK: - Properties

    /// Глобальный доступ к экземпляру стека Core Data.
    static let shared = CoreDataStack()

    /// Контейнер Core Data, инициализируемый моделью `ToDoDataModel`
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Ошибка инициализации CoreData: \(error)")
            }
        }
        return container
    }()

    /// Основной контекст для работы с данными.
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Functions

    /// Сохраняет изменения в контексте `viewContext`
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            try? context.save()
        }
    }
}

