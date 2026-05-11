import Foundation

struct ThreadReply: Codable, Identifiable, Hashable {
    let id: String
    let postId: String
    let authorId: String
    let authorName: String
    let authorRole: String     // "Learner" | "Mentor"
    let body: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, body
        case postId = "post_id"
        case authorId = "author_id"
        case authorName = "author_name"
        case authorRole = "author_role"
        case createdAt = "created_at"
    }
}

struct ThreadPost: Codable, Identifiable, Hashable {
    let id: String
    let authorId: String
    let authorName: String
    let title: String
    let body: String
    let tags: [String]
    let createdAt: String
    let replies: [ThreadReply]

    enum CodingKeys: String, CodingKey {
        case id, title, body, tags, replies
        case authorId = "author_id"
        case authorName = "author_name"
        case createdAt = "created_at"
    }
}
