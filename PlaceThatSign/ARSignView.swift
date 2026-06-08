import SwiftUI
import CoreLocation

struct ARSignView: View {
    @Environment(LocationService.self) private var locationService

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 64))
                    .foregroundStyle(.white.opacity(0.6))
                Text("AR view coming soon")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.6))
            }

            VStack {
                coordinateOverlay
                    .padding(.top, 16)
                Spacer()
                Button(action: {}) {
                    Label("Place Sign", systemImage: "signpost.right")
                        .font(.headline)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(.ultraThinMaterial, in: Capsule())
                }
                .padding(.bottom, 32)
            }
        }
    }

    @ViewBuilder
    private var coordinateOverlay: some View {
        if let coord = locationService.coordinate {
            Text("\(coord.latitude, specifier: "%.6f"), \(coord.longitude, specifier: "%.6f")")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
        } else {
            Text("Acquiring GPS…")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.white.opacity(0.6))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
        }
    }
}

#Preview {
    ARSignView()
        .environment(LocationService())
}
