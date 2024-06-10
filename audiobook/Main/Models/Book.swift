//
//  Book.swift
//  audiobook
//
//  Created by Pavlo Chornei  on 05.06.2024.
//

import Foundation
import Dependencies
import ComposableArchitecture

struct Book: Codable, Equatable {
    
    static func == (lhs: Book, rhs: Book) -> Bool {
        lhs.audioUrl == rhs.audioUrl
    }
    
    let coverUrl: String
    let keyPoints: [KeyPoint]
    let audioUrl: String
    let bookLenght: Double
}

struct KeyPoint: Codable, Equatable {
    let timestamp: String
    let title: String
}

protocol BookFetchable {
    func fetch() async throws -> Book
}

struct APIClient {
    var fetch: () async throws -> Book
 
    
    struct Failure: Error {}
}

extension APIClient {
    static let live = Self(
        fetch: {
            do {
                try await Task.sleep(for: .seconds(2))
                 let book = Book(
                    coverUrl: "https://img0-placeit-net.s3-accelerate.amazonaws.com/uploads/stage/stage_image/40050/optimized_large_thumb_stage.jpg",
                    keyPoints: [
                        KeyPoint(timestamp: "00-45", title: "The turtle wins the race"),
                        KeyPoint(timestamp: "01-00", title: "Float like a feather, sting like a bee."),
                        KeyPoint(timestamp: "01-38", title: "Si vi pacem para belum."),
                        KeyPoint(timestamp: "01-55", title: "OK Computer.")
                    ],
                    audioUrl: "https://cdn.pixabay.com/audio/2022/03/10/audio_b195486a22.mp3", bookLenght: 300)
                return book
            } catch {
                throw error
            }
        }
    )
}

enum BookFetchingError: Error, Equatable {
    case networkError
    case decodingError
    case unknownError
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClientKey.self] }
        set { self[APIClientKey.self] = newValue }
    }
}

private struct APIClientKey: DependencyKey {
    static let liveValue: APIClient = .live
    static var testValue: APIClient = .live
}
