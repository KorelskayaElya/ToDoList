//
//  ToDoModel.swift
//  ToDoList
//
//  Created by Эля Корельская on 04.08.2025.
//

import Foundation

struct TaskModel {
    /// Идентицикатор задачи
    var id: Int?
    /// Заголовок задачи
    var title: String?
    /// Описание задачи
    var description: String?
    /// Дата создания задачи
    var createdAt: Date?
    /// Флаг, указывающий, завершена ли задача
    var isCompleted: Bool?
}

