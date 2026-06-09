import SwiftUI
import CoreLocation

struct ARSignView: View {
    @Environment(LocationService.self) private var locationService
    @Environment(SignService.self) private var signService

    @State private var isPlacingSign = false
    @State private var placementErrorMessage: String?

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
                Button(action: { isPlacingSign = true }) {
                    Label("Place Sign", systemImage: "signpost.right")
                        .font(.headline)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(.ultraThinMaterial, in: Capsule())
                }
                .disabled(locationService.coordinate == nil)
                .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $isPlacingSign) {
            PlaceSignSheet { message in
                placeSign(message: message)
            }
        }
        .alert("Couldn't place sign",
               isPresented: Binding(
                get: { placementErrorMessage != nil },
                set: { if !$0 { placementErrorMessage = nil } }
               ),
               presenting: placementErrorMessage) { _ in
            Button("OK", role: .cancel) { }
        } message: { msg in
            Text(msg)
        }
    }

    private func placeSign(message: String) {
        guard let coordinate = locationService.coordinate else { return }
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        do {
            _ = try signService.place(message: trimmed, at: coordinate, author: "Oliver")
            isPlacingSign = false
        } catch {
            placementErrorMessage = error.localizedDescription
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

private struct PlaceSignSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var message: String = ""
    @FocusState private var isMessageFocused: Bool

    let onPlace: (String) -> Void

    private var trimmedMessage: String {
        message.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isValid: Bool {
        !trimmedMessage.isEmpty && message.count <= Sign.maxMessageLength
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("e.g. Jeff was here.", text: $message, axis: .vertical)
                        .lineLimit(3...6)
                        .focused($isMessageFocused)
                } header: {
                    Text("Sign message")
                } footer: {
                    HStack {
                        Spacer()
                        Text("\(message.count)/\(Sign.maxMessageLength)")
                            .font(.caption)
                            .foregroundStyle(message.count > Sign.maxMessageLength ? .red : .secondary)
                    }
                }
            }
            .navigationTitle("New Sign")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Place") { onPlace(message) }
                        .disabled(!isValid)
                }
            }
            .onAppear { isMessageFocused = true }
        }
    }
}

#Preview {
    ARSignView()
        .environment(LocationService())
        .environment(SignService())
}
