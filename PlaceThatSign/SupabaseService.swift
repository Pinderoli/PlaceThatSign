import Foundation
import CoreLocation
import Observation
import Supabase

@Observable
final class SupabaseService {
    private let client: SupabaseClient?

    var isConfigured: Bool { client != nil }

    init() {
        if let urlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
           !urlString.isEmpty,
           let url = URL(string: urlString),
           let anonKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String,
           !anonKey.isEmpty {
            self.client = SupabaseClient(supabaseURL: url, supabaseKey: anonKey)
        } else {
            print("⚠️ SupabaseService: missing SUPABASE_URL / SUPABASE_ANON_KEY in Info.plist. Running offline. Most common cause: stale build — try Product > Clean Build Folder (⇧⌘K) and rebuild.")
            self.client = nil
        }
    }

    enum ConfigError: LocalizedError {
        case notConfigured
        var errorDescription: String? {
            "Supabase isn't configured for this build. Network calls will fail until Secrets.xcconfig values reach Info.plist."
        }
    }

    private struct SignInsert: Encodable {
        let message: String
        let latitude: Double
        let longitude: Double
        let author: String
    }

    @discardableResult
    func insertSign(message: String, latitude: Double, longitude: Double, author: String) async throws -> Sign {
        guard let client else { throw ConfigError.notConfigured }
        let payload = SignInsert(message: message, latitude: latitude, longitude: longitude, author: author)
        let inserted: Sign = try await client
            .from("Signs")
            .insert(payload)
            .select()
            .single()
            .execute()
            .value
        return inserted
    }

    // Phase 1: pulls all rows and filters client-side. Replace with a PostGIS RPC
    // (`signs_within_radius`) once the table grows beyond a few hundred rows.
    func fetchNearbySigns(lat: Double, lng: Double, radiusMetres: Double) async throws -> [Sign] {
        guard let client else { throw ConfigError.notConfigured }
        let all: [Sign] = try await client
            .from("Signs")
            .select()
            .execute()
            .value

        let centre = CLLocation(latitude: lat, longitude: lng)
        return all.filter {
            CLLocation(latitude: $0.latitude, longitude: $0.longitude).distance(from: centre) <= radiusMetres
        }
    }
}
