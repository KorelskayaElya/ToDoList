//
//  ToDoListModuleBuilder.swift
//  ToDoList
//
//  Created by Эля Корельская on 04.08.2025.
//
import UIKit
/// Создаёт и возвращает готовый к использованию `ToDoListViewController`
final class ToDoListModuleBuilder {
    static func build() -> UIViewController {
        // View
        let view = ToDoListViewController()
        // Interactor
        let interactor = ToDoListInteractor()
        // Presenter
        let presenter = ToDoListPresenter()
        // Router
        let router = ToDoListRouter()

        // Связывание компонентов
        view.presenter = presenter

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router

        interactor.presenter = presenter

        router.viewController = view

        return view
    }
}

