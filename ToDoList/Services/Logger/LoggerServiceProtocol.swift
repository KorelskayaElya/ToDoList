//
//  LoggerServiceProtocol.swift
//  ToDoList
//
//  Created by Эля Корельская on 05.08.2025.
//

import UIKit

protocol LoggerService: AnyObject {
    func logEvent(message: String, type: LoggerEventType)
}
