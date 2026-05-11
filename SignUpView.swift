import SwiftUI

struct SignUpView: View {
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
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

                    // Trust stats
                    HStack(spacing: 8) {
                        TrustBox(value: "2.4k", label: "Mentors")
                        TrustBox(value: "94%",  label: "Match rate")
                        TrustBox(value: "Free", label: "Always")
                    }
                    .padding(.bottom, 18)

                    // Eyebrow
                    Text("Get started")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppColors.primary)
                        .padding(.bottom, 4)

                    Text("Create your account")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.bottom, 4)

                    Text("Join thousands of students getting real guidance.")
                        .font(.system(size: 13)).foregroundColor(AppColors.textTertiary)
                        .padding(.bottom, 20)

                    // Fields
                    AuthField(label: "Full name", placeholder: "Alex Johnson", text: $fullName)
                    AuthField(label: "School email", placeholder: "you@university.edu", text: $email, keyboardType: .emailAddress)
                    AuthField(label: "Password", placeholder: "••••••••••", text: $password, isSecure: true)

                    // Sign up button
                    Button(action: { currentScreen = .questionnaire }) {
                        Text("Create account")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppColors.primary)
                            .cornerRadius(12)
                    }
                    .padding(.top, 6)

                    // Divider
                    AuthDivider()

                    // Google
                    GoogleButton(action: { currentScreen = .questionnaire })

                    // Switch to login
                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .font(.system(size: 13)).foregroundColor(AppColors.textTertiary)
                        Button("Sign in") { currentScreen = .login }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppColors.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 14)

                    // Terms
                    Text("By signing up you agree to our Terms and Privacy Policy")
                        .font(.system(size: 11)).foregroundColor(AppColors.textTertiary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 10)
                }
                .padding(20)
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}
