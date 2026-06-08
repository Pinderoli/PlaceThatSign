import SwiftUI
import MapKit

struct MySignsView: View {
    @Environment(SignService.self) private var signService

    enum ViewMode: Hashable { case list, map }
    @State private var viewMode: ViewMode = .list

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("View", selection: $viewMode) {
                    Text("List").tag(ViewMode.list)
                    Text("Map").tag(ViewMode.map)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                if viewMode == .list {
                    List(signService.signs) { sign in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(sign.message)
                                .font(.body)
                            Text("\(sign.latitude, specifier: "%.4f"), \(sign.longitude, specifier: "%.4f")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.plain)
                } else {
                    Map {
                        ForEach(signService.signs) { sign in
                            Marker(sign.message, coordinate: CLLocationCoordinate2D(latitude: sign.latitude, longitude: sign.longitude))
                        }
                        UserAnnotation()
                    }
                    .ignoresSafeArea(edges: .bottom)
                }
            }
            .navigationTitle("My Signs")
        }
    }
}

#Preview {
    MySignsView()
        .environment(SignService())
}
