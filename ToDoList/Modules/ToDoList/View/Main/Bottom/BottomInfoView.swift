//
//  BottomInfoView.swift
//  ToDoList
//
//  Created by Эля Корельская on 07.08.2025.
//

import UIKit

protocol BottomInfoViewDelegate: AnyObject {
    func didTapAddTask()
}

final class BottomInfoView: UIView {

    // MARK: - Enum

    private enum InfoView {
        static let height: CGFloat = 100
    }

    private enum Icon {
        static let width: CGFloat = 48
        static let height: CGFloat = 48
        static let trailing: CGFloat = -16
    }

    // MARK: - UI

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Colors.Text.gray
        label.font = Fonts.sfProDisplayMediumFont(size: 13)
        label.text = "0 " + "Tasks".localized
        return label
    }()

    private let addIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "AddIconYellow")
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    // MARK: - Delegate

    weak var delegate: BottomInfoViewDelegate?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupGesture()
    }

    // MARK: - Public
    
    /// Обновляет текст информационного лейбла количеством задач
    /// - Parameter count: количество задач
    func updateTaskCount(_ count: Int) {
        let text = String.localizedStringWithFormat(
            NSLocalizedString("tasks_count", comment: "Количество задач"),
            count
        )
        infoLabel.text = text
    }

    ///  Включает или отключает возможность добавления новой задачи
    /// - Parameter isEnabled:`true` — кнопка активна, прозрачность иконки 100%, клики доступны
    ///`false` — кнопка неактивна, прозрачность иконки уменьшена до 50%, клики отключены
    func setAddEnabled(_ isEnabled: Bool) {
        addIconView.alpha = isEnabled ? 1.0 : 0.5
        addIconView.isUserInteractionEnabled = isEnabled
    }

    // MARK: - Private

    /// Настраивает внешний вид и компоновку элементов в представлении
    private func setupView() {
        backgroundColor = Colors.Background.black
        addSubview(infoLabel)
        addSubview(addIconView)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: InfoView.height),

            infoLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            infoLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            addIconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            addIconView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Icon.trailing),
            addIconView.widthAnchor.constraint(equalToConstant: Icon.width),
            addIconView.heightAnchor.constraint(equalToConstant: Icon.height)
        ])
    }

    /// Настраивает обработчик нажатия на иконку добавления задачи
    private func setupGesture() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(addTapped)
        )
        addIconView.addGestureRecognizer(tap)
    }

    /// Обработчик нажатия на иконку добавления задачи
    @objc private func addTapped() {
        delegate?.didTapAddTask()
    }
}

