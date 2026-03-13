//
//  CreateComparisonModalViewController.swift
//  ChooseRight!
//
//  Modal for creating a new comparison: dismiss ✕, full-width primary and secondary buttons.
//

import UIKit

final class CreateComparisonModalViewController: UIViewController {

    var onCreateByDescription: ((String) -> Void)?
    var onFillManually: ((String) -> Void)?
    var onDismiss: (() -> Void)?

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let dismissButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("✕", for: .normal)
        b.setTitleColor(.label, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = NSLocalizedString("Create new comparison", comment: "")
        l.font = .sfProTextBold33()
        l.textColor = .label
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let hintLabel: UILabel = {
        let l = UILabel()
        let examples = NSLocalizedString("For example:\n• Compare New York and London by cost of living, technology, price.\n• Compare Apples, Pears, and Peaches.", comment: "Create comparison alert examples")
        let hint = NSLocalizedString("Or enter the name of your comparison if you want to fill in the objects and parameters yourself.", comment: "Create comparison alert hint")
        l.text = examples + "\n\n" + hint
        l.font = .sfProTextRegular16()
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let textField: UITextField = {
        let t = UITextField()
        t.placeholder = NSLocalizedString("e.g. Compare 5 cities", comment: "")
        t.autocapitalizationType = .sentences
        t.clearButtonMode = .always
        t.borderStyle = .roundedRect
        t.backgroundColor = .tertiarySystemFill
        t.font = .sfProTextRegular16()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()

    private let createByDescriptionButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle(NSLocalizedString("Create by description", comment: ""), for: .normal)
        b.titleLabel?.font = .sfProTextSemibold18()
        b.setTitleColor(.black, for: .normal)
        b.backgroundColor = UIColor.specialColors.threeBlueLavender ?? .systemBlue
        b.layer.cornerRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let fillManuallyButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle(NSLocalizedString("Fill manually", comment: ""), for: .normal)
        b.titleLabel?.font = .sfProTextRegular16()
        b.setTitleColor(.secondaryLabel, for: .normal)
        b.backgroundColor = .tertiarySystemFill
        b.layer.cornerRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let dimmingView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.overrideUserInterfaceStyle = .light

        view.addSubview(dimmingView)
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        let tapOutside = UITapGestureRecognizer(target: self, action: #selector(dismissTapped))
        dimmingView.addGestureRecognizer(tapOutside)
        containerView.addSubview(dismissButton)
        containerView.addSubview(titleLabel)
        containerView.addSubview(hintLabel)
        containerView.addSubview(textField)
        containerView.addSubview(createByDescriptionButton)
        containerView.addSubview(fillManuallyButton)

        let padding: CGFloat = 20
        let spacing: CGFloat = 12

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            dismissButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            dismissButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            dismissButton.widthAnchor.constraint(equalToConstant: 44),
            dismissButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: dismissButton.leadingAnchor, constant: -8),

            hintLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: spacing),
            hintLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            hintLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),

            textField.topAnchor.constraint(equalTo: hintLabel.bottomAnchor, constant: spacing),
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            textField.heightAnchor.constraint(equalToConstant: 44),

            createByDescriptionButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: spacing + 8),
            createByDescriptionButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            createByDescriptionButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            createByDescriptionButton.heightAnchor.constraint(equalToConstant: 50),

            fillManuallyButton.topAnchor.constraint(equalTo: createByDescriptionButton.bottomAnchor, constant: spacing),
            fillManuallyButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            fillManuallyButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            fillManuallyButton.heightAnchor.constraint(equalToConstant: 50),
            fillManuallyButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding)
        ])

        dismissButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        createByDescriptionButton.addTarget(self, action: #selector(createByDescriptionTapped), for: .touchUpInside)
        fillManuallyButton.addTarget(self, action: #selector(fillManuallyTapped), for: .touchUpInside)

        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        textField.delegate = self

        createByDescriptionButton.isEnabled = false
    }

    @objc private func dismissTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onDismiss?()
        }
    }

    @objc private func textFieldChanged() {
        let trimmed = (textField.text ?? "").trimmingCharacters(in: .whitespaces)
        createByDescriptionButton.isEnabled = !trimmed.isEmpty
    }

    @objc private func createByDescriptionTapped() {
        let trimmed = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        dismiss(animated: true) { [weak self] in
            self?.onCreateByDescription?(trimmed)
        }
    }

    @objc private func fillManuallyTapped() {
        let trimmed = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let name = trimmed.isEmpty ? NSLocalizedString("New comparison", comment: "") : trimmed
        dismiss(animated: true) { [weak self] in
            self?.onFillManually?(name)
        }
    }
}

extension CreateComparisonModalViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
