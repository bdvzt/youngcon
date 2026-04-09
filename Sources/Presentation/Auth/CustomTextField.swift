import SwiftUI
import UIKit

struct CustomTextField: UIViewRepresentable {
    @Binding var text: String

    let placeholder: String
    let isSecure: Bool
    let keyboardType: UIKeyboardType

    func makeUIView(context: Context) -> InsetTextField {
        let textField = InsetTextField()

        textField.delegate = context.coordinator
        textField.text = text
        textField.placeholder = placeholder
        textField.isSecureTextEntry = isSecure
        textField.keyboardType = keyboardType

        textField.textColor = .white
        textField.tintColor = .white
        textField.backgroundColor = UIColor(AppColor.cardBackground)

        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.white.withAlphaComponent(0.06).cgColor

        textField.font = .systemFont(ofSize: 16, weight: .medium)
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor.white.withAlphaComponent(0.25),
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            ]
        )

        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.smartInsertDeleteType = .no
        textField.spellCheckingType = .no
        textField.textContentType = isSecure ? .password : .emailAddress
        textField.returnKeyType = isSecure ? .done : .next
        textField.clearButtonMode = .whileEditing
        textField.clipsToBounds = true
        textField.contentVerticalAlignment = .center

        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        textField.addTarget(
            context.coordinator,
            action: #selector(Coordinator.textDidChange(_:)),
            for: .editingChanged
        )

        return textField
    }

    func updateUIView(_ uiView: InsetTextField, context _: Context) {
        if uiView.text != text {
            uiView.text = text
        }

        if uiView.isSecureTextEntry != isSecure {
            uiView.isSecureTextEntry = isSecure
        }

        if uiView.placeholder != placeholder {
            uiView.placeholder = placeholder
            uiView.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [
                    .foregroundColor: UIColor.white.withAlphaComponent(0.25),
                    .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                ]
            )
        }

        if uiView.keyboardType != keyboardType {
            uiView.keyboardType = keyboardType
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        @objc
        func textDidChange(_ textField: UITextField) {
            text = textField.text ?? ""
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
}

final class InsetTextField: UITextField {
    private let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 44)

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: insets)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: insets)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: insets)
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 52)
    }
}
