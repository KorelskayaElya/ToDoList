//
//  ToDoListView+TableView.swift
//  ToDoList
//
//  Created by Эля Корельская on 05.08.2025.
//

import UIKit

// MARK: - UITableViewDataSource

extension ToDoListViewController: UITableViewDataSource {

    // MARK: - Functions

    func setupTableView() {
        tableView.register(
            ToDoListTableCell.self,
            forCellReuseIdentifier: ToDoListTableCell.reuseIdentifier
        )
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = Colors.Background.black
        tableView.rowHeight = 106
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = Colors.Text.gray
        navigationItem.searchController = searchController
        definesPresentationContext = true

        tableView.sectionHeaderHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            tableView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            )
        ])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ToDoListTableCell.reuseIdentifier,
            for: indexPath
        ) as? ToDoListTableCell else {
            return UITableViewCell()
        }
        let task = tasks[indexPath.row]
        cell.configure(with: task)
        cell.onCheckmarkTap = { [weak self] in
            guard let self = self else { return }
            var updatedTask = task
            updatedTask.isCompleted = !(task.isCompleted ?? false)
            self.presenter?.updateTask(updatedTask)
        }
        return cell
    }

    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        let task = tasks[indexPath.row]
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { _ in
            let edit = UIAction(
                title: "Edit".localized,
                image: UIImage(named:"EditIconGray")
            ) { _ in
                self.presenter?.didSelectTask(task)
            }

            let share = UIAction(
                title: "Share".localized,
                image: UIImage(named: "ExportIcon")
            ) { _ in
                let activityVC = UIActivityViewController(
                    activityItems: [task.title ?? ""],
                    applicationActivities: nil
                )
                self.present(activityVC, animated: true)
            }

            let delete = UIAction(
                title: "Delete".localized,
                image: UIImage(named: "TrashIcon"),
                attributes: .destructive
            ) { _ in
                self.presenter?.deleteTask(task)
            }

            return UIMenu(title: "", children: [edit, share, delete])
        }
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {

        let task = tasks[indexPath.row]

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete".localized) { [weak self] _, _, completion in
            self?.presenter?.deleteTask(task)
            completion(true)
        }
        let trashImage = UIImage(named: "TrashIcon")?
            .withTintColor(Colors.Text.gray, renderingMode: .alwaysOriginal)

        deleteAction.image = trashImage
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = true
        return config
    }

}

// MARK: - UITableViewDelegate

extension ToDoListViewController: UITableViewDelegate {

    // MARK: - Functions

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        presenter?.didSelectTask(task)
    }

    /// фиксированная высота ячейки (как в фигме)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 106
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView()
    }
}


