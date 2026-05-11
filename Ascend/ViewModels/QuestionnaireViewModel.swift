import Foundation

@MainActor
final class QuestionnaireViewModel: ObservableObject {
    @Published var isFirstGen = false
    @Published var interestTrack: String = "Financial"   // or "Tech"
    @Published var preferredExperienceYears: Int = 10
    @Published var financialGoals: String = ""
    @Published var careerGoals: String = ""

    @Published var matchedMentor: MentorProfile?
    @Published var isSubmitting = false
    @Published var errorMessage: String?

    let learnerId: String

    init(learnerId: String = "l1") {
        self.learnerId = learnerId
    }

    func submit() async {
        isSubmitting = true
        defer { isSubmitting = false }

        let answers = QuestionnaireAnswers(
            learnerId: learnerId,
            isFirstGen: isFirstGen,
            interestTrack: interestTrack,
            financialGoals: split(financialGoals),
            careerGoals: split(careerGoals),
            preferredExperienceYears: preferredExperienceYears
        )
        do {
            let mentor: MentorProfile = try await NetworkManager.shared.post(
                "/questionnaire", body: answers
            )
            matchedMentor = mentor
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func split(_ raw: String) -> [String] {
        raw.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }
}
