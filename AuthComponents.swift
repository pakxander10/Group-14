import SwiftUI

//Auth Screen Flow
enum AuthScreen {
    case signUp
    case login
    case questionnaire
    case home
}

//Auth Root
struct AuthRootView: View {
    @State private var currentScreen: AuthScreen = .signUp

    var body: some View {
        switch currentScreen {
        case .signUp:
            SignUpView(currentScreen: $currentScreen)
        case .login:
            LoginView(currentScreen: $currentScreen)
        case .questionnaire:
            MatchView() // your questionnaire screen
        case .home:
            ContentView() // your main tab view
        }
    }
}

//Reusable Auth Field
struct AuthField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 12)).foregroundColor(AppColors.textTertiary)
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                        .autocapitalization(.none)
                }
            }
            .font(.system(size: 14))
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background(Color(hex: "#f9f9f9"))
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(
                text.isEmpty ? Color.gray.opacity(0.15) : AppColors.primaryBorder,
                lineWidth: 0.5))
        }
        .padding(.bottom, 10)
    }
}

// Divider
struct AuthDivider: View {
    var body: some View {
        HStack(spacing: 10) {
            Rectangle().fill(Color.gray.opacity(0.15)).frame(height: 0.5)
            Text("or").font(.system(size: 12)).foregroundColor(AppColors.textTertiary)
            Rectangle().fill(Color.gray.opacity(0.15)).frame(height: 0.5)
        }
        .padding(.vertical, 14)
    }
}

//Google Button
struct GoogleButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Circle().fill(AppColors.primary).frame(width: 16, height: 16)
                Text("Continue with Google")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#444444"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 0.5))
        }
        .padding(.bottom, 4)
    }
}

// Trust stat box
struct TrustBox: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value).font(.system(size: 16, weight: .bold)).foregroundColor(AppColors.primary)
            Text(label).font(.system(size: 10)).foregroundColor(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(hex: "#f9f9f9"))
        .cornerRadius(10)
    }
}
