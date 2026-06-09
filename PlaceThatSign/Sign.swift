import Foundation

struct Sign: Identifiable, Codable {
    static let maxMessageLength = 100

    let id: UUID
    let latitude: Double
    let longitude: Double
    let message: String
    let author: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, latitude, longitude, message, author
        case createdAt = "created_at"
    }
}
