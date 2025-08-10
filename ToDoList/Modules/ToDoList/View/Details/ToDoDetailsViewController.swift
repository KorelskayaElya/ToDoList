//
//  ToDoDetailsViewController.swift
//  ToDoList
//
//  Created by Эля Корельская on 05.08.2025.
//

import UIKit

/// Экран отображения подробной информации о выбранной задаче
final class ToDoDetailsViewController: UIViewController, UITextViewDelegate {

    // MARK: - Properties

    private var task: TaskModel
    private let detailsView = ToDoDetailsView()
    var onUpdateTask: ((TaskModel) -> Void)?

    // MARK: - Init

    init(task: TaskModel) {
        self.task = task
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = detailsView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        detailsView.descriptionTextView.becomeFirstResponder()
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        setupCustomBackButton()
        detailsView.configure(with: task)
        detailsView.onDescriptionChange = { [weak self] newText in
            guard var task = self?.task else { return }
            task.description = newText
            self?.task = task
            self?.onUpdateTask?(task)
        }
    }

    // MARK: - Private

    /// Установка кастомной левой кнопки
    private func setupCustomBackButton() {
        let backButton = UIButton(type: .system)
        backButton.setImage(
            UIImage(named: "ChevronIcon")?.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        backButton.tintColor = Colors.Text.yellow
        backButton.setTitle("Back".localized, for: .normal)
        backButton.setTitleColor(Colors.Text.yellow, for: .normal)
        backButton.titleLabel?.font = Fonts.sfProDisplayBoldFont(size: 22)
        backButton.addTarget(
            self, action: #selector(backButtonTapped),
            for: .touchUpInside
        )

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }

    /// Обработка нажатия на кнопку назад
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    func textViewDidChange(_ textView: UITextView) {
        task.description = textView.text
        if let presenter = (navigationController?.viewControllers.first as? ToDoListViewController)?.presenter {
            presenter.updateTask(task)
        }
    }
}
