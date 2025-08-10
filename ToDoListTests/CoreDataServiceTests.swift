//
//  CoreDataServiceTests.swift
//  ToDoListTests
//
//  Created by Эля Корельская on 09.08.2025.
//

import XCTest
@testable import ToDoList
import CoreData

final class CoreDataServiceTests: XCTestCase {

    // MARK: - Properties

    var coreDataService: CoreDataService!
    var context: NSManagedObjectContext!

    // MARK: - Setup / Teardown

    /// Создаёт новый in-memory Core Data контекст и инициализирует `coreDataService`
    override func setUp() {
        super.setUp()
        context = makeInMemoryContext()
        coreDataService = CoreDataService(context: context)
    }

    /// Освобождает ресурсы после теста
    override func tearDown() {
        coreDataService = nil
        context = nil
        super.tearDown()
    }

    // MARK: - Tests

    /// Проверяет, что задача сохраняется и корректно извлекается из Core Data
    func testSaveAndFetchTasks() {
        let task = TaskModel(id: 1, title: "Test", description: "Desc", createdAt: Date(), isCompleted: false)
        coreDataService.save(task: task)
        let fetched = coreDataService.fetchTasks()

        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.title, "Test")
    }

    /// Проверяет, что существующая задача корректно обновляется
    func testUpdateTask() {
        let original = TaskModel(id: 1, title: "Test", description: "Desc", createdAt: Date(), isCompleted: false)
        coreDataService.save(task: original)

        let updated = TaskModel(id: 1, title: "Updated", description: "New desc", createdAt: original.createdAt, isCompleted: true)
        coreDataService.update(task: updated)

        let fetched = coreDataService.fetchTasks()
        XCTAssertEqual(fetched.count, 1)
        let t = fetched.first { $0.id == 1 }
        XCTAssertEqual(t?.title, "Updated")
        XCTAssertEqual(t?.description, "New desc")
        XCTAssertEqual(t?.isCompleted, true)
    }

    /// Проверяет, что задача удаляется из Core Data
    func testDeleteTask() {
        let task = TaskModel(id: 1, title: "Test", description: "Desc", createdAt: Date(), isCompleted: false)
        coreDataService.save(task: task)
        coreDataService.delete(task: task)

        let fetched = coreDataService.fetchTasks()
        XCTAssertTrue(fetched.isEmpty)
    }

    /// Создаёт in-memory `NSManagedObjectContext` с загруженной моделью `ToDoDataModel`
    /// для выполнения тестов без обращения к реальному хранилищу
    private func makeInMemoryContext() -> NSManagedObjectContext {
        let bundle = Bundle(for: CoreDataService.self)

        guard
            let modelURL = bundle.url(forResource: "ToDoDataModel", withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: modelURL)
        else {
            fatalError("[ToDoDataModel] не найдена")
        }

        let container = NSPersistentContainer(name: "ToDoDataModel", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        return container.viewContext
    }
}
