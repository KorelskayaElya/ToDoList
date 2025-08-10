//
//  NetworkServiceTests.swift
//  ToDoListTests
//
//  Created by Эля Корельская on 09.08.2025.
//
import XCTest
@testable import ToDoList

final class NetworkServiceTests: XCTestCase {

    /// Проверяет успешный сценарий загрузки задач методом `fetchTodos`
    func testFetchTodosSuccess() {
        let exp = expectation(description: "Fetch todos")

        let mockData = """
        { "todos": [ { "id": 1, "todo": "Test", "completed": false, "userId": 1 } ] }
        """.data(using: .utf8)!

        URLProtocolMock.requestHandler = { _ in
            return (
                HTTPURLResponse(
                    url: URL(string: "https://dummyjson.com/todos")!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                mockData
            )
        }

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        let session = URLSession(configuration: config)
        let service = NetworkService(session: session)

        service.fetchTodos { tasks in
            XCTAssertEqual(tasks.count, 1)
            XCTAssertEqual(tasks.first?.description, "Test")
            exp.fulfill()
        } failure: { error in
            XCTFail("Should not fail: \(error)")
        }

        waitForExpectations(timeout: 1)
    }
}

// MARK: - Мок для URLProtocol
/// Класс-мок для перехвата и эмуляции сетевых запросов в `URLSession`
class URLProtocolMock: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = URLProtocolMock.requestHandler else { return }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
