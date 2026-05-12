//
//  LoginView.swift
//  Group-14 — Features/Auth/Views
//
//  Lightweight "look up by id" login flow. Backend has no real auth.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @AppStorage("userId")   private var userId:   String = ""
    @AppStorage("userRole") private var userRole: String = ""

    var body: some View {
        ZStack {
            Color.ascendBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    header

                    rolePicker
                    idField

                    if case .failed(let message) = viewModel.state {
                        Text(message)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }

                    submitButton

                    hint
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
            }
        }
        .navigationTitle("Log In")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.state) { _, newValue in
            if case .loggedIn(let role, let id) = newValue {
                userId = id
                userRole = role.storageValue
            }
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("Welcome back")
                .font(.title2.bold())
                .foregroundColor(.ascendTextPrimary)
            Text("Enter the user id you were given on signup.")
                .font(.subheadline)
                .foregroundColor(.ascendTextSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var rolePicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("I am a…")
                .font(.caption)
                .foregroundColor(.ascendTextSecondary)
            Picker("Role", selection: $viewModel.role) {
                Text("Learner").tag(UserRole.learner)
                Text("Mentor").tag(UserRole.mentor)
            }
            .pickerStyle(.segmented)
        }
    }

    private var idField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("User ID")
                .font(.caption)
                .foregroundColor(.ascendTextSecondary)
            TextField("e.g. u1 or m1", text: $viewModel.enteredId)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
        }
    }

    private var submitButton: some View {
        Button {
            viewModel.submit()
        } label: {
            HStack {
                if case .verifying = viewModel.state {
                    ProgressView().tint(.white)
                } else {
                    Text("Log In").font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(viewModel.canSubmit ? Color.ascendAccent : Color.ascendSurface)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!viewModel.canSubmit || viewModel.state == .verifying)
    }

    private var hint: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Demo accounts")
                .font(.caption.bold())
                .foregroundColor(.ascendTextSecondary)
            Text("Learner: u1 (Sofia Rodriguez)\nMentors: m1 (Priya), m2 (Jordan), m3 (Amara)")
                .font(.caption)
                .foregroundColor(.ascendTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.ascendSurface)
        )
    }
}

#Preview {
    NavigationStack { LoginView() }
}
