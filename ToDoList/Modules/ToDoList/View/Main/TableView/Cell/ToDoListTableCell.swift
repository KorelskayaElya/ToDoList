//
//  ToDoListTableCell.swift
//  ToDoList
//
//  Created by Эля Корельская on 05.08.2025.
//

import UIKit

/// Ячейка таблицы для отображения задачи в списке.
final class ToDoListTableCell: UITableViewCell {

    // MARK: - Enums

    private enum Icon {
        static let leading: CGFloat = 12
        static let top: CGFloat = 12
        static let width: CGFloat = 48
        static let height: CGFloat = 48
    }

    private enum StackView {
        static let leading: CGFloat = 8
        static let trailing: CGFloat = -8
        static let top: CGFloat = 8
        static let bottom: CGFloat = -8
        static let spacing: CGFloat = 10
    }

    private enum DateLabel {
        static let top: CGFloat = 4
    }

    // MARK: - Properties

    static let reuseIdentifier = "ToDoListTableCell"
    var onCheckmarkTap: (() -> Void)?

    // MARK: - UI

    private lazy var iconButton: UIButton = {
        let button = UIButton(type: .system)
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(checkmarkTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.sfProDisplayBoldFont(size: 16)
        label.textColor = Colors.Text.gray
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.sfProDisplayMediumFont(size: 14)
        label.textColor = Colors.Text.gray
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.sfProDisplayLightFont(size: 12)
        label.textColor = Colors.Text.gray
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var stackView = UIStackView.buildVerticalViews(views:[titleLabel, descriptionLabel])

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions

    private func setupUI() {
        backgroundColor = Colors.Background.black
        selectionStyle = .none
        stackView.spacing = StackView.spacing

        contentView.addSubview(iconButton)
        contentView.addSubview(stackView)
        contentView.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            iconButton.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Icon.leading
            ),
            iconButton.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Icon.top
            ),
            iconButton.widthAnchor.constraint(
                equalToConstant: Icon.width
            ),
            iconButton.heightAnchor.constraint(
                equalToConstant: Icon.height
            ),

            stackView.leadingAnchor.constraint(
                equalTo: iconButton.trailingAnchor,
                constant: StackView.leading
            ),
            stackView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: StackView.top
            ),
            stackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: StackView.trailing
            ),

            dateLabel.topAnchor.constraint(
                greaterThanOrEqualTo: stackView.bottomAnchor,
                constant: DateLabel.top
            ),
            dateLabel.leadingAnchor.constraint(
                equalTo: stackView.leadingAnchor
            ),
            dateLabel.trailingAnchor.constraint(
                equalTo: stackView.trailingAnchor
            ),
            dateLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: StackView.bottom
            )
        ])
    }

    /// Настраивает отображение ячейки задачи на основе переданной модели `TaskModel`.
    /// - Parameter task: Переданная модель `TaskModel`.
    func configure(with task: TaskModel) {
        let imageName = (task.isCompleted ?? false) ? "CheckMarkOn" : "CheckMarkOff"
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        iconButton.setImage(image, for: .normal)

        let titleText = "Task".localized  + " \(task.id ?? 0)"
        if task.isCompleted ?? false {
            let attributed = NSAttributedString(
                string: titleText,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                             .foregroundColor: Colors.Text.gray]
            )
            titleLabel.attributedText = attributed
        } else {
            titleLabel.attributedText = NSAttributedString(
                string: titleText,
                attributes: [.foregroundColor: Colors.Text.gray]
            )
        }

        descriptionLabel.text = task.description
        dateLabel.text = task.createdAt?.toShortString()
    }

    /// Настраивает отображение иконки  о выполнении задачи и отображение заголовка
    @objc private func checkmarkTapped() {
        onCheckmarkTap?()
    }

}

