import SwiftUI
import UIKit

// MARK: - Custom TextField with UIKit

struct CustomTextField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    let isSecure: Bool
    let keyboardType: UIKeyboardType

    init(text: Binding<String>, placeholder: String, isSecure: Bool = false, keyboardType: UIKeyboardType = .default) {
        _text = text
        self.placeholder = placeholder
        self.isSecure = isSecure
        self.keyboardType = keyboardType
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.text = text
        textField.delegate = context.coordinator
        textField.textColor = .white
        textField.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1)
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.6)]
        )
        textField.keyboardType = keyboardType
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none

        // Отступы слева
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always

        if isSecure {
            textField.isSecureTextEntry = true
        }

        return textField
    }

    func updateUIView(_ uiView: UITextField, context _: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }

        func textField(_: UITextField, shouldChangeCharactersIn _: NSRange, replacementString string: String) -> Bool {
            if string.isEmpty { return true }

            let allowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@._%+-")
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
    }
}

// MARK: - LoginView

struct LoginView: View {
    // MARK: - Properties

    @EnvironmentObject private var loginState: LoginState
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""

    // MARK: - Computed Properties

    private var isEmailValid: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return email.isEmpty || emailPredicate.evaluate(with: email)
    }

    private var isPasswordValid: Bool {
        password.count >= 6
    }

    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && isEmailValid && isPasswordValid
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            contentView
        }
        .alert("Ошибка", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Content View

    private var contentView: some View {
        VStack(spacing: 40) {
            headerView

            VStack(spacing: 16) {
                emailTextField

                if !email.isEmpty, !isEmailValid {
                    emailErrorText
                }

                passwordTextField

                if !password.isEmpty, !isPasswordValid {
                    passwordErrorText
                }
            }
            .padding(.horizontal, 24)

            loginButton

            Spacer()
        }
        .padding(.vertical, 32)
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(spacing: 12) {
            logoView

            gradientTextView

            Text("Войдите, чтобы продолжить")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.top, 40)
    }

    // MARK: - Logo View

    private var logoView: some View {
        Image(uiImage: YoungConAsset.logo.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 150, height: 150)
            .shadow(color: YoungConAsset.accentYellow.swiftUIColor.opacity(0.6), radius: 15)
    }

    // MARK: - Gradient Text View

    private var gradientTextView: some View {
        Text("Добро пожаловать")
            .font(.title)
            .fontWeight(.bold)
            .overlay {
                LinearGradient(
                    colors: [
                        YoungConAsset.accentYellow.swiftUIColor,
                        YoungConAsset.accentPurple.swiftUIColor,
                        YoungConAsset.accentPink.swiftUIColor,
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .mask(
                    Text("Добро пожаловать")
                        .font(.title)
                        .fontWeight(.bold)
                )
            }
    }

    // MARK: - Text Fields

    private var emailTextField: some View {
        CustomTextField(
            text: $email,
            placeholder: "Email",
            isSecure: false,
            keyboardType: .emailAddress
        )
        .frame(height: 52)
        .onChange(of: email) { _, _ in
            if !email.isEmpty, !isEmailValid {
                errorMessage = "Введите корректный email (пример: name@domain.com)"
            }
        }
    }

    private var emailErrorText: some View {
        HStack {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.caption)
                .foregroundColor(YoungConAsset.accentPink.swiftUIColor)

            Text("Неверный формат email")
                .font(.caption)
                .foregroundColor(YoungConAsset.accentPink.swiftUIColor)

            Spacer()
        }
        .padding(.leading, 4)
        .transition(.opacity)
    }

    private var passwordTextField: some View {
        CustomTextField(
            text: $password,
            placeholder: "Пароль",
            isSecure: true,
            keyboardType: .asciiCapable
        )
        .frame(height: 52)
    }

    private var passwordErrorText: some View {
        HStack {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.caption)
                .foregroundColor(YoungConAsset.accentPink.swiftUIColor)

            Text("Пароль должен содержать не менее 6 символов")
                .font(.caption)
                .foregroundColor(YoungConAsset.accentPink.swiftUIColor)

            Spacer()
        }
        .padding(.leading, 4)
        .transition(.opacity)
    }

    // MARK: - Login Button

    private var loginButton: some View {
        Button(action: performLogin) {
            if loginState.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                Text("Войти")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 52)
        .background(loginButtonBackground)
        .cornerRadius(16)
        .disabled(loginState.isLoading || !isFormValid)
        .opacity((loginState.isLoading || !isFormValid) ? 0.6 : 1)
        .padding(.horizontal, 24)
    }

    // MARK: - Gradients & Backgrounds

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                YoungConAsset.appBackground.swiftUIColor,
                YoungConAsset.cardBackground.swiftUIColor,
                Color(red: 0.05, green: 0.05, blue: 0.15),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var loginButtonBackground: some View {
        Color(red: 0.15, green: 0.15, blue: 0.25)
    }

    // MARK: - Actions

    private func performLogin() {
        // Проверка email
        guard isEmailValid else {
            errorMessage = "Пожалуйста, введите корректный email адрес"
            showError = true
            return
        }

        // Проверка пароля
        guard password.count >= 6 else {
            errorMessage = "Пароль должен содержать не менее 6 символов"
            showError = true
            return
        }

        guard !password.isEmpty else {
            errorMessage = "Пожалуйста, введите пароль"
            showError = true
            return
        }

        Task {
            _ = await loginState.login(email: email, password: password)
            if loginState.isLoggedIn {
                dismiss()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    LoginView()
        .environmentObject(LoginState())
}
