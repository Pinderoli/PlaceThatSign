import Foundation
import CoreLocation
import Observation

@Observable
class SignService {

    // MARK: - Placement constraints
    static let arRenderRadius: Double       = 500   // metres — signs shown as floating AR anchors
    static let nearbyFeedRadius: Double     = 2_000 // metres — signs shown in list/feed
    static let notificationRadius: Double   = 200   // metres — future push trigger
    static let maxSignsPerDay               = 3     // free tier daily cap
    static let minimumSignSpacing: Double   = 50    // metres — prevents stacking own signs

    // Dev toggle — set to `true` to re-enable the daily cap, spacing rule, and message length cap.
    // Kept off during early development so seed data doesn't block placement testing.
    static let enforcePlacementLimits = false

    // MARK: - State
    private(set) var signs: [Sign] = [
        Sign(id: UUID(), latitude: 51.2802, longitude: 1.0789, message: "Jeff was here.", author: "Oliver", createdAt: .now),
        Sign(id: UUID(), latitude: 51.2798, longitude: 1.0781, message: "Lots of mud ahead.", author: "Oliver", createdAt: .now),
        Sign(id: UUID(), latitude: 51.2810, longitude: 1.0795, message: "I made it! 2026.", author: "Oliver", createdAt: .now),
    ]

    // MARK: - Filtered views

    func signsForAR(near location: CLLocation) -> [Sign] {
        signs.filter { distanceTo($0, from: location) <= Self.arRenderRadius }
    }

    func signsForFeed(near location: CLLocation) -> [Sign] {
        signs.filter { distanceTo($0, from: location) <= Self.nearbyFeedRadius }
    }

    // MARK: - Placement

    enum PlacementError: LocalizedError {
        case messageTooLong
        case dailyLimitReached
        case tooCloseToExistingSign(metres: Int)

        var errorDescription: String? {
            switch self {
            case .messageTooLong:
                return "Signs must be \(Sign.maxMessageLength) characters or less."
            case .dailyLimitReached:
                return "You've placed \(SignService.maxSignsPerDay) signs today. Come back tomorrow!"
            case .tooCloseToExistingSign(let metres):
                return "Too close to one of your signs (\(metres)m away). Minimum spacing is \(Int(SignService.minimumSignSpacing))m."
            }
        }
    }

    func place(message: String, at coordinate: CLLocationCoordinate2D, author: String) throws -> Sign {
        if Self.enforcePlacementLimits {
            guard message.count <= Sign.maxMessageLength else {
                throw PlacementError.messageTooLong
            }

            let signsToday = signs.filter { Calendar.current.isDateInToday($0.createdAt) }
            guard signsToday.count < Self.maxSignsPerDay else {
                throw PlacementError.dailyLimitReached
            }

            let newLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            for existing in signs {
                let d = distanceTo(existing, from: newLocation)
                if d < Self.minimumSignSpacing {
                    throw PlacementError.tooCloseToExistingSign(metres: Int(d))
                }
            }
        }

        let sign = Sign(id: UUID(), latitude: coordinate.latitude, longitude: coordinate.longitude,
                        message: message, author: author, createdAt: .now)
        signs.append(sign)
        return sign
    }

    // MARK: - Helpers

    private func distanceTo(_ sign: Sign, from location: CLLocation) -> Double {
        CLLocation(latitude: sign.latitude, longitude: sign.longitude).distance(from: location)
    }

}
