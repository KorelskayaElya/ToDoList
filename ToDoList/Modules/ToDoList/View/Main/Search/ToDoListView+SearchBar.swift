//
//  ToDoListView+SearchBar.swift
//  ToDoList
//
//  Created by Эля Корельская on 05.08.2025.
//

import UIKit

extension ToDoListViewController: UISearchResultsUpdating {

    // MARK: - Enum

    private enum Icon {
        static let width: CGFloat = 20
        static let height: CGFloat = 20
        static let trailing: CGFloat = -8
    }

    // MARK: - Functions

    /// Настраивает компонент поиска (`UISearchController`)
    func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = Colors.Text.gray

        configureSearchTextField()
        searchController.searchBar.showsBookmarkButton = true
        let grayMic = UIImage(named: "MicrofonIcon")?
            .withTintColor(
                Colors.Text.gray,
                renderingMode: .alwaysOriginal
            )
        searchController.searchBar.setImage(
            grayMic,
            for: .bookmark,
            state: .normal
        )
        searchController.searchBar.setImage(
            grayMic,
            for: .bookmark,
            state: .highlighted
        )

        searchController.searchBar.delegate = self

        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    /// Извлекает введённую строку поиска и передаёт её в `presenter` для фильтрации задач
    /// - Parameter searchController:контроллер поиска с текстом
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else { return }
        presenter?.searchTasks(query: query)
    }

    // MARK: - Private Functions

    /// Настраивает `UITextField` внутри `UISearchBar`
    private func configureSearchTextField() {
        let textField = searchController.searchBar.searchTextField
        textField.overrideUserInterfaceStyle = .dark
        textField.tintColor = Colors.Text.gray
        textField.textColor = Colors.Text.gray
        textField.defaultTextAttributes = [
            .foregroundColor: Colors.Text.gray,
            .font: Fonts.sfProDisplayMediumFont(size: 16)
        ]
        textField.typingAttributes = [
            .foregroundColor: Colors.Text.gray,
            .font: Fonts.sfProDisplayMediumFont(size: 16)
        ]
        textField.attributedPlaceholder = NSAttributedString(
            string: "SearchPlaceholder".localized,
            attributes: [.foregroundColor: Colors.Text.gray]
        )
        textField.clearButtonMode = .never
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(forceGrayText),
            name: UITextField.textDidChangeNotification,
            object: textField
        )
        searchController.searchBar.setImage(
            UIImage(named: "SearchIcon"),
            for: .search,
            state: .normal
        )
    }

    /// Принудительно восстанавливает серый цвет текста в поле поиска
    @objc private func forceGrayText() {
        let textField = searchController.searchBar.searchTextField
        let attrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: Colors.Text.gray,
            .font: Fonts.sfProDisplayMediumFont(size: 16)
        ]
        let selected = textField.selectedTextRange
        let current = textField.text ?? ""
        textField.attributedText = NSAttributedString(
            string: current,
            attributes: attrs
        )
        if let selected { textField.selectedTextRange = selected }
        textField.typingAttributes = attrs
        textField.textColor = Colors.Text.gray
    }
}
