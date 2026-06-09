import Foundation
import CoreLocation
import Observation
import Supabase

@Observable
final class SupabaseService {
    private let client: SupabaseClient

    init() {
        guard
            let urlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
            let url = URL(string: urlString),
            let anonKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String,
            !urlString.isEmpty, !anonKey.isEmpty
        else {
            fatalError("Missing SUPABASE_URL / SUPABASE_ANON_KEY in Info.plist. Did you wire up Secrets.xcconfig?")
        }
        self.client = SupabaseClient(supabaseURL: url, supabaseKey: anonKey)
    }

    private struct SignInsert: Encodable {
        let message: String
        let latitude: Double
        let longitude: Double
        let author: String
    }

    @discardableResult
    func insertSign(message: String, latitude: Double, longitude: Double, author: String) async throws -> Sign {
        let payload = SignInsert(message: message, latitude: latitude, longitude: longitude, author: author)
        let inserted: Sign = try await client
            .from("signs")
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
        let all: [Sign] = try await client
            .from("signs")
            .select()
            .execute()
            .value

        let centre = CLLocation(latitude: lat, longitude: lng)
        return all.filter {
            CLLocation(latitude: $0.latitude, longitude: $0.longitude).distance(from: centre) <= radiusMetres
        }
    }
}
