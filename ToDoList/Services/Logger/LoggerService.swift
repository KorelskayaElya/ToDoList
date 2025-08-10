//
//  LoggerService.swift
//  ToDoList
//
//  Created by Эля Корельская on 05.08.2025.
//

import UIKit
import OSLog

/// Реализация протокола `LoggerService` с использованием `OSLog`
final class OSLogLogger: LoggerService {

    // MARK: - Properties

    static let shared: LoggerService = OSLogLogger()

    private let log: OSLog? = {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            return nil
        }
        return OSLog(subsystem: bundleIdentifier, category: "Logger")
    }()

    private let queue = DispatchQueue(label: "logger.serialQueue")

    // MARK: - Init

    private init() {}

    // MARK: - Internal

    /// Записывает сообщение в системный лог
    ///
    /// - Parameters:
    ///   - message: Сообщение, которое необходимо записать
    ///   - type: Тип события (`LoggerEventType`), который будет преобразован в `OSLogType`
    ///
    /// #### Соответствие типов:
    /// - `.warning` -`.info`
    /// - `.error` - `.error`
    /// - `.attention` - `.default`
    /// - `.other` - `.debug`
    ///
    /// Сообщение логируется асинхронно в отдельной очереди.
    func logEvent(message: String, type: LoggerEventType) {
        queue.async { [weak self] in
            guard let self = self, let log = self.log else {
                return
            }
            var logType: OSLogType

            switch type {
            case .warning:
                logType = .info
            case .error:
                logType = .error
            case .attention:
                logType = .default
            case .other:
                logType = .debug
            }
            os_log("%@", log: log, type: logType, message)
        }
    }
}

