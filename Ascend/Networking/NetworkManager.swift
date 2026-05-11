import Foundation

enum APIError: Error, LocalizedError {
    case badURL
    case badResponse(Int)
    case decoding(Error)
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .badURL: return "Invalid URL"
        case .badResponse(let code): return "Server returned \(code)"
        case .decoding(let e): return "Decode failed: \(e.localizedDescription)"
        case .transport(let e): return "Network error: \(e.localizedDescription)"
        }
    }
}

/// Singleton networking client targeting the local FastAPI dev server.
/// On a physical device, change `baseURL` to your Mac's LAN IP.
final class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = URL(string: "http://127.0.0.1:8000")!
    private let session: URLSession = .shared
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private init() {}

    func get<T: Decodable>(_ path: String) async throws -> T {
        try await send(path: path, method: "GET", body: Optional<Empty>.none)
    }

    func post<B: Encodable, T: Decodable>(_ path: String, body: B) async throws -> T {
        try await send(path: path, method: "POST", body: body)
    }

    func put<B: Encodable, T: Decodable>(_ path: String, body: B) async throws -> T {
        try await send(path: path, method: "PUT", body: body)
    }

    // MARK: - Internals

    private struct Empty: Encodable {}

    private func send<B: Encodable, T: Decodable>(
        path: String, method: String, body: B?
    ) async throws -> T {
        var req = URLRequest(url: baseURL.appendingPathComponent(path))
        req.httpMethod = method
        if let body, !(body is Empty) {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try encoder.encode(body)
        }

        let data: Data
        let resp: URLResponse
        do {
            (data, resp) = try await session.data(for: req)
        } catch {
            throw APIError.transport(error)
        }

        guard let http = resp as? HTTPURLResponse else {
            throw APIError.badResponse(-1)
        }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.badResponse(http.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
}
