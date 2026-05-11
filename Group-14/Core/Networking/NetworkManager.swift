//
//  NetworkManager.swift
//  Group-14
//
//  Core networking layer — all ViewModels talk through this class.
//  Base URL targets local FastAPI server during development.
//

import Foundation

// MARK: - NetworkError

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case decodingFailed(Error)
    case serverError(Int)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:           return "Invalid URL."
        case .decodingFailed(let e): return "Decoding failed: \(e.localizedDescription)"
        case .serverError(let c):   return "Server returned \(c)."
        case .unknown(let e):       return e.localizedDescription
        }
    }
}

// MARK: - NetworkManagerProtocol

protocol NetworkManagerProtocol {
    func get<T: Decodable>(_ path: String) async throws -> T
    func post<Body: Encodable, Response: Decodable>(_ path: String, body: Body) async throws -> Response
    func put<Body: Encodable, Response: Decodable>(_ path: String, body: Body) async throws -> Response
}

// MARK: - NetworkManager

final class NetworkManager: NetworkManagerProtocol {

    static let shared = NetworkManager()

    private let baseURL = "http://127.0.0.1:8000"
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()
    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        return e
    }()

    private init() {}

    // MARK: GET

    func get<T: Decodable>(_ path: String) async throws -> T {
        guard let url = URL(string: baseURL + path) else { throw NetworkError.invalidURL }

        let (data, response) = try await URLSession.shared.data(from: url)
        try validateResponse(response)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }

    // MARK: POST

    func post<Body: Encodable, Response: Decodable>(_ path: String, body: Body) async throws -> Response {
        guard let url = URL(string: baseURL + path) else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }

    // MARK: PUT

    func put<Body: Encodable, Response: Decodable>(_ path: String, body: Body) async throws -> Response {
        guard let url = URL(string: baseURL + path) else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }

    // MARK: Private

    private func validateResponse(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200..<300).contains(http.statusCode) else {
            throw NetworkError.serverError(http.statusCode)
        }
    }
}
