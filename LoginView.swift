import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @Binding var currentScreen: AuthScreen

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // Hero band
                VStack(spacing: 6) {
                    HStack {
                        Text("Invest").font(.system(size: 28, weight: .bold)).foregroundColor(AppColors.primaryDark)
                        + Text("InMe").font(.system(size: 28, weight: .bold)).foregroundColor(AppColors.primary)
                        Spacer()
                    }
                    Text("Connect with verified finance professionals")
                        .font(.system(size: 13)).foregroundColor(AppColors.primaryMid)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(20)
                .background(AppColors.primaryLight)

                VStack(alignment: .leading, spacing: 0) {

                    // Eyebrow
                    Text("Welcome back")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppColors.primary)
                        .padding(.bottom, 4)

                    Text("Sign in to your account")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.bottom, 4)

                    Text("Good to see you again.")
                        .font(.system(size: 13)).foregroundColor(AppColors.textTertiary)
                        .padding(.bottom, 20)

                    // Fields
                    AuthField(label: "Email", placeholder: "you@university.edu", text: $email, keyboardType: .emailAddress)

                    // Password with show/hide
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Password")
                            .font(.system(size: 12)).foregroundColor(AppColors.textTertiary)
                        HStack {
                            if showPassword {
                                TextField("••••••••••", text: $password)
                                    .font(.system(size: 14))
                            } else {
                                SecureField("••••••••••", text: $password)
                                    .font(.system(size: 14))
                            }
                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.textTertiary)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 11)
                        .background(Color(hex: "#f9f9f9"))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.15), lineWidth: 0.5))
                    }
                    .padding(.bottom, 6)

                    // Forgot password
                    HStack {
                        Spacer()
                        Button("Forgot password?") { }
                            .font(.system(size: 12)).foregroundColor(AppColors.primary)
                    }
                    .padding(.bottom, 14)

                    // Sign in button
                    Button(action: { currentScreen = .home }) {
                        Text("Sign in")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppColors.primary)
                            .cornerRadius(12)
                    }

                    // Divider
                    AuthDivider()

                    // Google
                    GoogleButton(action: { currentScreen = .home })

                    // Switch to sign up
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .font(.system(size: 13)).foregroundColor(AppColors.textTertiary)
                        Button("Sign up") { currentScreen = .signUp }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppColors.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 14)
                }
                .padding(20)
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}
