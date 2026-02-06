import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var showResetPassword = false
    @State private var resetEmail = ""
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // Logo / Title
                VStack(spacing: 8) {
                    Text("T.O.D.O")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(.orange)

                    Text("Task-Oriented Delay Obliterator")
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

                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)
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

                // Buttons
                VStack(spacing: 12) {
                    Button {
                        Task {
                            await authViewModel.signIn(email: email, password: password)
                        }
                    } label: {
                        Text("Sign In")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(email.isEmpty || password.isEmpty)

                    Button("Forgot Password?") {
                        resetEmail = email
                        showResetPassword = true
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 32)

                Spacer()

                // Sign Up Link
                HStack {
                    Text("Don't have an account?")
                        .foregroundStyle(.secondary)
                    Button("Sign Up") {
                        showSignUp = true
                    }
                    .fontWeight(.semibold)
                }
                .font(.subheadline)
                .padding(.bottom, 24)
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
            .alert("Reset Password", isPresented: $showResetPassword) {
                TextField("Email", text: $resetEmail)
                Button("Send Reset Link") {
                    Task {
                        await authViewModel.resetPassword(email: resetEmail)
                        showResetConfirmation = true
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enter your email address to receive a password reset link.")
            }
            .alert("Check Your Email", isPresented: $showResetConfirmation) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("If an account exists for that email, a password reset link has been sent.")
            }
        }
    }
}
