import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    private var passwordsMatch: Bool {
        !password.isEmpty && password == confirmPassword
    }

    private var isFormValid: Bool {
        !email.isEmpty && password.count >= 6 && passwordsMatch
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Header
            VStack(spacing: 8) {
                Text("Create Account")
                    .font(.system(size: 32, weight: .bold, design: .rounded))

                Text("Start obliterating procrastination")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Form
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)

                SecureField("Password (min 6 characters)", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)

                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)

                if !confirmPassword.isEmpty && !passwordsMatch {
                    Text("Passwords don't match")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            .padding(.horizontal, 32)

            // Error
            if let error = authViewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            // Sign Up Button
            Button {
                Task {
                    await authViewModel.signUp(email: email, password: password)
                }
            } label: {
                Text("Create Account")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!isFormValid)
            .padding(.horizontal, 32)

            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
