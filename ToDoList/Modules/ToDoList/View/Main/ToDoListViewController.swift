//
//  ToDoListViewController.swift
//  ToDoList
//
//  Created by Эля Корельская on 04.08.2025.
//

import UIKit

protocol ToDoListViewProtocol: AnyObject {
    func displayTasks(_ tasks: [TaskModel])
    func showError(message: String)
}
/// Экран со списком задач
final class ToDoListViewController: UIViewController, ToDoListViewProtocol {

    // MARK: - Properties

    var presenter: ToDoListPresenterProtocol?
    private let speechService = SpeechService()
    var tasks: [TaskModel] = []
    private var isSearchEnabled = false

    // MARK: - UI

    lazy var tableView = UITableView(frame: .zero, style: .plain)
    lazy var searchController = UISearchController(
        searchResultsController: nil
    )
    private lazy var bottomView = BottomInfoView()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = Colors.Text.gray
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        bottomView.setAddEnabled(false)
        setSearchEnabled(false)
        activityIndicator.startAnimating()
        presenter?.fetchTasks()
        speechService.delegate = self
        speechService.prepareAuthorization()
    }

    // MARK: - UI Setup

    /// Установка компонентов UI
    private func setupUI() {
        view.backgroundColor = Colors.Background.black
        setupSearchBar()
        setupTableView()
        configureMicrophoneVisibility()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.delegate = self

        view.addSubview(activityIndicator)
        view.addSubview(bottomView)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            activityIndicator.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            bottomView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            bottomView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            bottomView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
        ])
    }

    /// Установка навигационного бара
    private func setupNavigationBar() {
        title = "TasksNavTitle".localized
        navigationController?.navigationBar.prefersLargeTitles = true
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Colors.Background.black
        appearance.titleTextAttributes = [.foregroundColor: Colors.Text.gray]
        appearance.largeTitleTextAttributes = [.foregroundColor: Colors.Text.gray]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    /// Показывает/скрывает кнопку «микрофон» в поисковой строке в зависимости от системного языка
    private func configureMicrophoneVisibility() {
        #if targetEnvironment(simulator)
        searchController.searchBar.showsBookmarkButton = false
        #else
        let isRu: Bool
        if #available(iOS 16.0, *) {
            isRu = (Locale.current.language.languageCode?.identifier.lowercased() == "ru")
        } else {
            isRu = ((Locale.current.languageCode?.lowercased()) == "ru")
        }
        searchController.searchBar.showsBookmarkButton = isRu
        #endif
    }

    /// Применяет единый набор атрибутов (цвет/шрифт) к текстовому полю поиска
    private func applySearchTextAttributes() {
        let textField = searchController.searchBar.searchTextField
        let attrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: Colors.Text.gray,
            .font: Fonts.sfProDisplayMediumFont(size: 16)
        ]
        textField.overrideUserInterfaceStyle = .dark
        textField.tintColor = Colors.Text.gray
        textField.typingAttributes = attrs
        textField.textColor = Colors.Text.gray

        let selected = textField.selectedTextRange
        let current = textField.text ?? ""
        textField.attributedText = NSAttributedString(
            string: current,
            attributes: attrs
        )
        if let selected {
            textField.selectedTextRange = selected
        }
    }

    /// Настраивает `UITextField` внутри `UISearchBar`
    private func configureSearchTextField() {
        let textField = searchController.searchBar.searchTextField
        textField.clearButtonMode = .never

        applySearchTextAttributes()
        textField.addTarget(
            self,
            action: #selector(userEditedSearchField),
            for: .editingChanged
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onSearchTextDidChange),
            name: UITextField.textDidChangeNotification,
            object: textField
        )
    }

    /// Обработка ручного изменения текста во время активного прослушивания
    @objc private func userEditedSearchField(_ textField: UITextField) {
        guard speechService.isListening else { return }
        speechService.stop()
        setMicActive(false)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.applySearchTextAttributes()
            self.setMicActive(true)
            self.speechService.start()
        }
    }

    /// Реакция на системное уведомление изменения текста в поле поиска
    @objc private func onSearchTextDidChange() {
        applySearchTextAttributes()
    }

    /// Включает или отключает функциональность поиска
    /// - Parameter enabled: `true` — поиск включён,
    /// `false` — поиск отключён (поле поиска становится полупрозрачным и недоступным)
    private func setSearchEnabled(_ enabled: Bool) {
        isSearchEnabled = enabled
        let textfield = searchController.searchBar.searchTextField
        textfield.isEnabled = enabled
        textfield.alpha = enabled ? 1.0 : 0.5
        searchController.searchBar.isUserInteractionEnabled = enabled
    }

    // MARK: - Public

    /// Отображает список задач в таблице.
    ///
    /// Используется Presenter'ом для передачи полученных задач во View.
    /// Обновляет локальное хранилище задач и перезагружает `UITableView`.
    ///
    /// - Parameter tasks: Массив задач для отображения.
    func displayTasks(_ tasks: [TaskModel]) {
        self.tasks = tasks
        bottomView.updateTaskCount(tasks.count)
        bottomView.setAddEnabled(true)
        activityIndicator.stopAnimating()
        setSearchEnabled(true)
        tableView.reloadData()
    }

    /// Показывает сообщение об ошибке в виде алерта.
    ///
    /// Вызывается Presenter'ом при неудачной загрузке данных из сети или базы данных.
    ///
    /// - Parameter message: Текст сообщения, отображаемый в алерте.
    func showError(message: String) {
        activityIndicator.stopAnimating()
        setSearchEnabled(true)
        let okAction = UIAlertAction(title: "ОК".localized, style: .default, handler: nil)
        let alert = AlertHelper.buildAlertWithActions(
            title: "ErrorLoadingTitle".localized,
            message: message,
            actions: [okAction]
        )
        present(alert, animated: true, completion: nil)
    }

    /// Переключает внешний вид кнопки «микрофон» в поисковой строке
    private func setMicActive(_ active: Bool) {
        let base = UIImage(named: "MicrofonIcon") ?? UIImage()
        let img = base.withTintColor(active ? Colors.Text.yellow : Colors.Text.gray,
                                     renderingMode: .alwaysOriginal)
        let bar = searchController.searchBar
        bar.setImage(img, for: .bookmark, state: .normal)
        bar.setImage(img, for: .bookmark, state: .highlighted)
    }

    /// Обрабатывает нажатие на кнопку «микрофон» (bookmark) в поисковой строке
    /// Если поиск выключен — ничего не делает
    /// Если прослушивание активно — останавливает распознавание и возвращает серую иконку
    /// Если не активно — очищает поле, применяет атрибуты, включает жёлтую иконку и запускает распознавание
    @objc func searchBarRightIconTapped() {
        guard isSearchEnabled else { return }

        #if targetEnvironment(simulator)
        let alert = UIAlertController(title: "Недоступно в симуляторе",
                                      message: "Распознавание речи работает только на реальном устройстве.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
        #else
        if speechService.isListening {
            setMicActive(false)
            speechService.stop()
        } else {
            let tf = searchController.searchBar.searchTextField
            tf.text = ""
            applySearchTextAttributes()
            setMicActive(true)
            speechService.start()
        }
        #endif
    }
}
// MARK: - BottomInfoViewDelegate

extension ToDoListViewController: BottomInfoViewDelegate {
    /// Обрабатывает нажатие на кнопку добавления задачи в `BottomInfoView`
    /// Вызывает у презентера метод `addTask(title:description:)` с локализованными значениями
    /// для заголовка и описания новой задачи
    func didTapAddTask() {
        presenter?.addTask(
            title: "NewTaskTitle".localized,
            description: "NewTaskDescription".localized
        )
    }
}
// MARK: - SpeechServiceDelegate

extension ToDoListViewController: SpeechServiceDelegate {
    /// Получает частичные и финальные результаты распознавания и синхронизирует поле поиска
    ///
    /// Вызывается сервисом распознавания речи при получении нового текста
    /// (как промежуточного, так и финального). Обновляет текст в `UISearchBar`
    /// и выполняет поиск задач через `presenter`
    ///
    /// - Parameters:
    ///   - service: Экземпляр `SpeechService`, отправивший обновление.
    ///   - text: Распознанный текст.
    func speechService(_ service: SpeechService, didUpdate text: String) {
        let textField = searchController.searchBar.searchTextField
        textField.text = text
        applySearchTextAttributes()
        DispatchQueue.main.async {
            [weak self] in
            self?.applySearchTextAttributes()
        }
        presenter?.searchTasks(query: text)
    }

    /// Вызывается при завершении работы распознавания речи
    /// - Parameter service: Экземпляр `SpeechService`, завершивший работу.
    func speechServiceDidFinish(_ service: SpeechService) {
        setMicActive(false)
    }

    /// Обрабатывает ошибку, возникшую при распознавании речи
    ///
    /// Отображает пользователю сообщение об ошибке
    ///
    /// - Parameters:
    ///   - service: Экземпляр `SpeechService`, в котором произошла ошибка
    ///   - error: Ошибка, описывающая причину сбоя
    func speechService(_ service: SpeechService, didFail error: Error) {
        setMicActive(false)
        showError(message: error.localizedDescription)
    }
}
extension ToDoListViewController: UISearchBarDelegate {
    /// Обрабатывает нажатие на кнопку микрофона в строке поиска.
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        searchBarRightIconTapped()
    }
}
