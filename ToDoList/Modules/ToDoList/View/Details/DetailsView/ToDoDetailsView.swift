//
//  ToDoDetailsView.swift
//  ToDoList
//
//  Created by Эля Корельская on 05.08.2025.
//

import UIKit

/// кастомный UIView, отображающий детали задачи
final class ToDoDetailsView: UIView {

    // MARK: - Enum

    private enum Stack {
        static let spacing: CGFloat = 16
        static let top: CGFloat = 20
        static let leading: CGFloat = 30
        static let trailing: CGFloat = -30
        static let bottom: CGFloat = -20
    }

    private enum ScrollView {
        static let padding: CGFloat = 20
    }

    private enum DescriptionTextView {
        static let height: CGFloat = 100
        static let maxCharacters: Int = 400
    }

    // MARK: - Properties

    var onDescriptionChange: ((String) -> Void)?

    // MARK: - UI

    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.keyboardDismissMode = .interactive
        return scroll
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.sfProDisplayBoldFont(size: 34)
        label.textColor = Colors.Text.gray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.sfProDisplayBoldFont(size: 12)
        label.textColor = Colors.Text.gray
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var descriptionTextView: UITextView = {
        let text = UITextView()
        text.backgroundColor = .clear
        text.textColor = Colors.Text.gray
        text.font = Fonts.sfProDisplayBoldFont(size: 16)
        text.isEditable = true
        text.isScrollEnabled = false
        text.textContainerInset = .zero
        text.textContainer.lineFragmentPadding = 0
        text.translatesAutoresizingMaskIntoConstraints = false
        text.delegate = self
        return text
    }()

    lazy var stack = UIStackView.verticalStack(
        arrangedSubviews: [
            titleLabel,
            dateLabel,
            descriptionTextView
        ]
    )

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupKeyboardObservers()
        setupHideKeyboardOnTap()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
        setupKeyboardObservers()
        setupHideKeyboardOnTap()
    }

    // MARK: - Setup

    private lazy var descriptionHeightConstraint =
    descriptionTextView.heightAnchor.constraint(
        greaterThanOrEqualToConstant: DescriptionTextView.height
    )

    private func setupUI() {
        backgroundColor = Colors.Background.black
        stack.spacing = Stack.spacing
        stack.alignment = .fill
    }

    private func setupConstraints() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(
                equalTo: topAnchor
            ),
            scrollView.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),
            scrollView.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),
            scrollView.bottomAnchor.constraint(
                equalTo: bottomAnchor
            ),

            contentView.topAnchor.constraint(
                equalTo: scrollView.topAnchor
            ),
            contentView.leadingAnchor.constraint(
                equalTo: scrollView.leadingAnchor
            ),
            contentView.trailingAnchor.constraint(
                equalTo: scrollView.trailingAnchor
            ),
            contentView.bottomAnchor.constraint(
                equalTo: scrollView.bottomAnchor
            ),
            contentView.widthAnchor.constraint(
                equalTo: scrollView.widthAnchor
            ),

            stack.topAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.topAnchor,
                constant: Stack.top
            ),
            stack.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Stack.leading
            ),
            stack.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: Stack.trailing
            ),
            stack.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: Stack.bottom
            ),
            descriptionHeightConstraint
        ])
    }

    // MARK: - Keyboard Handling

    /// Подписывает вью на системные уведомления о показе и скрытии клавиатуры
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    /// Обработчик события показа клавиатуры
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView.contentInset.bottom = keyboardFrame.height + ScrollView.padding
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardFrame.height + ScrollView.padding
    }

    /// Обработчик события скрытия клавиатуры.
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    // MARK: - Dismiss keyboard on tap

    /// Настраивает жест для скрытия клавиатуры при тапе по области `scrollView`
    /// Добавляет `UITapGestureRecognizer`, который вызывает метод `dismissKeyboard`
    private func setupHideKeyboardOnTap() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tap)
    }

    /// Закрывает клавиатуру, завершив редактирование в текущем окне
    @objc private func dismissKeyboard() {
        endEditing(true)
    }

    // MARK: - Configure

    /// Конфигурирует экран детализации задачи, заполняя UI-элементы данными из модели.
    /// - Parameter task: Объект `TaskModel`
    func configure(with task: TaskModel) {
        titleLabel.text = "Task".localized + " \(task.id ?? 0)"
        dateLabel.text = task.createdAt?.toShortString()
        descriptionTextView.text = task.description
    }
}

// MARK: - UITextViewDelegate

extension ToDoDetailsView: UITextViewDelegate {

    // MARK: - Ограничение ввода

    /// Лимитирует ввод в `descriptionTextView` по количеству символов, учитывая выделенный текст
    /// - Parameters:
    ///   - textView: `UITextView`
    ///   - range: диапазон доступных символов
    ///   - text: текст
    /// - Returns: `true`, если изменение текста разрешено (вставка, удаление или замена в пределах лимита символов `false` — если изменение превысит лимит и не должно быть выполнено
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        if let marked = textView.markedTextRange, textView.position(
            from: marked.start,
            offset: 0
        ) != nil {
            return true
        }
        let max = DescriptionTextView.maxCharacters
        let current = textView.text ?? ""

        guard let stringRange = Range(range, in: current) else { return false }
        let before = current.count - current[stringRange].count
        let proposedCount = before + text.count

        if proposedCount <= max {
            return true
        }
        let remaining = max - before
        if remaining <= 0 {
            return false
        }
        let endIndex = text.index(text.startIndex, offsetBy: remaining, limitedBy: text.endIndex) ?? text.endIndex
        let allowedText = String(text[..<endIndex])
        if let startPos = textView.position(from: textView.beginningOfDocument, offset: range.location),
           let endPos = textView.position(from: startPos, offset: range.length),
           let textRange = textView.textRange(from: startPos, to: endPos) {
            textView.replace(textRange, withText: allowedText)
        }
        return false
    }

    /// Вызывается при каждом изменении текста в `descriptionTextView`
    /// Передаёт обновлённый текст в колбэк `onDescriptionChange`
    /// - Parameter textView: Экземпляр `UITextView`, в котором произошло изменение текста
    func textViewDidChange(_ textView: UITextView) {
        onDescriptionChange?(textView.text)
    }
}

