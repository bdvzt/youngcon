import SwiftUI

struct LoginView: View {
    @ObservedObject var appViewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""

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
        .onChange(of: appViewModel.authError) { _, newError in
            if let error = newError {
                errorMessage = error
                showError = true
            }
        }
        .onChange(of: appViewModel.isAuthenticated) { _, isAuth in
            if isAuth {
                dismiss()
            }
        }
    }

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

    private var logoView: some View {
        Image("logo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 150, height: 150)
            .shadow(color: AppColor.accentYellow.opacity(0.6), radius: 15)
    }

    private var gradientTextView: some View {
        Text("Добро пожаловать")
            .font(.title)
            .fontWeight(.bold)
            .overlay {
                LinearGradient(
                    colors: [
                        AppColor.accentYellow,
                        AppColor.accentPurple,
                        AppColor.accentPink,
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

    private var emailTextField: some View {
        CustomTextField(
            text: $email,
            placeholder: "Email",
            isSecure: false,
            keyboardType: .emailAddress
        )
        .frame(maxWidth: .infinity, minHeight: 52, maxHeight: 52)
    }

    private var emailErrorText: some View {
        HStack {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.caption)
                .foregroundColor(AppColor.accentPink)

            Text("Неверный формат email")
                .font(.caption)
                .foregroundColor(AppColor.accentPink)

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
        .frame(maxWidth: .infinity, minHeight: 52, maxHeight: 52)
    }

    private var passwordErrorText: some View {
        HStack {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.caption)
                .foregroundColor(AppColor.accentPink)

            Text("Пароль должен содержать не менее 6 символов")
                .font(.caption)
                .foregroundColor(AppColor.accentPink)

            Spacer()
        }
        .padding(.leading, 4)
        .transition(.opacity)
    }

    private var loginButton: some View {
        Button(action: performLogin) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(loginButtonBackground)
                    .frame(height: 52)

                if appViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(tint: .white)
                        )
                } else {
                    Text("Войти")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(appViewModel.isLoading || !isFormValid)
        .opacity((appViewModel.isLoading || !isFormValid) ? 0.6 : 1)
        .padding(.horizontal, 24)
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                AppColor.appBackground,
                AppColor.cardBackground,
                Color(red: 0.05, green: 0.05, blue: 0.15),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var loginButtonBackground: Color {
        Color(red: 0.15, green: 0.15, blue: 0.25)
    }

    private func performLogin() {
        guard isEmailValid else {
            errorMessage = "Пожалуйста, введите корректный email адрес"
            showError = true
            return
        }

        guard password.count >= 6 else {
            errorMessage = "Пароль должен содержать не менее 6 символов"
            showError = true
            return
        }

        Task {
            await appViewModel.login(email: email, password: password)
        }
    }
}
