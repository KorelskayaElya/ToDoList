//
//  NetworkManager.swift
//  ToDoList
//
//  Created by Эля Корельская on 04.08.2025.
//

import Foundation
import OSLog

final class NetworkService {

    // MARK: - Enum

    enum Constants {
        static let baseURLString = "https://dummyjson.com/todos"
    }

    // MARK: - Properties

    static let shared = NetworkService()
    private let session: URLSession
    private let logger: LoggerService

    // MARK: - Init

    init(session: URLSession = .shared, logger: LoggerService = OSLogLogger.shared) {
        self.session = session
        self.logger = logger
    }

    // MARK: - Function

    /// Загружает список задач с удалённого сервера
    /// При возникновении ошибки (неверный URL, ошибка сети, отсутствие данных, ошибка декодирования)
    /// вызывает блок `failure` и пишет сообщение в лог
    ///
    /// - Parameters:
    ///   - completion: Замыкание, вызываемое при успешной загрузке и декодировании данных
    ///                 В параметре передаётся массив задач (`[TaskModel]`)
    ///   - failure: Замыкание, вызываемое при ошибке. В параметре передаётся объект `Error`
    ///
    /// - Note: Все ошибки логируются с помощью `logger` как события типа `.error`.
    func fetchTodos(
        completion: @escaping ([TaskModel]) -> Void,
        failure: @escaping (Error) -> Void
    ) {
        guard let url = URL(string: Constants.baseURLString) else {
            let error = NSError(domain: "NetworkService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Неверный URL"])
            failure(error)
            logger.logEvent(message: "[NetworkService] url error", type: .error)
            return
        }

        session.dataTask(with: url) { data, _, error in
            if let error = error {
                failure(error)
                self.logger.logEvent(message: "[NetworkService] dataTask error: \(error.localizedDescription)", type: .error)
                return
            }

            guard let data = data else {
                let error = NSError(domain: "NetworkService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Нет данных"])
                failure(error)
                self.logger.logEvent(message: "[NetworkService] no data", type: .error)
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(TodoResponse.self, from: data)
                let tasks = decoded.todos.map {
                    TaskModel(
                        id: $0.id,
                        title: "Task".localized + " \($0.id ?? 0)",
                        description: $0.todo,
                        createdAt: Date(),
                        isCompleted: $0.completed ?? false
                    )
                }
                completion(tasks)
            } catch {
                failure(error)
                self.logger.logEvent(message: "[NetworkService] decode error: \(error.localizedDescription)", type: .error)
            }
        }.resume()
    }
}
