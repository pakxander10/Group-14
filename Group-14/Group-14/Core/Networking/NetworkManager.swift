//
//  NetworkManager.swift
//  Group-14 — Core/Networking
//
//  Protocol-first async/await URLSession wrapper.
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
        case .invalidURL:             return "Invalid URL."
        case .decodingFailed(let e):  return "Decoding failed: \(e.localizedDescription)"
        case .serverError(let code):  return "Server error \(code)."
        case .unknown(let e):         return e.localizedDescription
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

final class NetworkManager: NetworkManagerProtocol, @unchecked Sendable {

    nonisolated static let shared = NetworkManager()

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

    func get<T: Decodable>(_ path: String) async throws -> T {
        guard let url = URL(string: baseURL + path) else { throw NetworkError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response)
        return try decode(T.self, from: data)
    }

    func post<Body: Encodable, Response: Decodable>(_ path: String, body: Body) async throws -> Response {
        let request = try makeRequest(path: path, method: "POST", body: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response)
        return try decode(Response.self, from: data)
    }

    func put<Body: Encodable, Response: Decodable>(_ path: String, body: Body) async throws -> Response {
        let request = try makeRequest(path: path, method: "PUT", body: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response)
        return try decode(Response.self, from: data)
    }

    // MARK: - Private helpers

    private func makeRequest<Body: Encodable>(path: String, method: String, body: Body) throws -> URLRequest {
        guard let url = URL(string: baseURL + path) else { throw NetworkError.invalidURL }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try encoder.encode(body)
        return req
    }

    private func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200..<300).contains(http.statusCode) else {
            throw NetworkError.serverError(http.statusCode)
        }
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}
