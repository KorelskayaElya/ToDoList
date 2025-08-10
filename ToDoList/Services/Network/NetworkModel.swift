//
//  TodoItem.swift
//  ToDoList
//
//  Created by Эля Корельская on 09.08.2025.
//

import UIKit

struct TodoResponse: Decodable {
    let todos: [TodoItem]
}

struct TodoItem: Decodable {
    let id: Int?
    let todo: String?
    let completed: Bool?
    let userId: Int?
}
