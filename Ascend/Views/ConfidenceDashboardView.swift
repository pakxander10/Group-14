import SwiftUI

struct ConfidenceDashboardView: View {
    @StateObject private var vm = ConfidenceViewModel()

    private var progress: Double { Double(vm.score) / 1000.0 }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 18)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [.indigo, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 18, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: progress)
                    VStack {
                        Text("\(vm.score)")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                        Text("/ 1000")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 240, height: 240)
                .padding(.top, 24)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Adjust your confidence")
                        .font(.headline)
                    Slider(
                        value: Binding(
                            get: { Double(vm.score) },
                            set: { vm.score = Int($0) }
                        ),
                        in: 1...1000,
                        step: 10
                    )
                }
                .padding(.horizontal)

                Button {
                    Task { await vm.save() }
                } label: {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.indigo)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Confidence")
            .task { await vm.load() }
        }
    }
}

#Preview { ConfidenceDashboardView() }
