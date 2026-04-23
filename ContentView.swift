import SwiftUI

struct ContentView: View {
    @State private var tipperIsPressedUp = false
    @State private var tipperIsPressedDown = false

    @State private var tarpDirection: TarpDirection = .stopped

    @State private var weightValue: Double = 0

    @State private var door1State: DoorDirection = .idle
    @State private var door2State: DoorDirection = .idle

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let sectionHeight = geometry.size.height / 5

                VStack(spacing: 12) {
                    tipperSection
                        .frame(height: sectionHeight - 9)

                    tarpSection
                        .frame(height: sectionHeight - 9)

                    scalesSection
                        .frame(height: sectionHeight - 9)

                    doorsSection
                        .frame(height: (sectionHeight * 2) - 6)
                }
                .padding(.horizontal, 14)
                .padding(.top, 8)
                .padding(.bottom, 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    LinearGradient(
                        colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .navigationTitle("Tipper")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    settingsMenu
                }
            }
        }
        .onAppear {
            tarpDirection = .stopped
        }
    }

    private var settingsMenu: some View {
        Menu {
            Menu("Tipper Bluetooth") {
                Button("Pair Device") { }
                Button("Forget Device", role: .destructive) { }
            }

            Menu("Tarp Bluetooth") {
                Button("Pair Device") { }
                Button("Forget Device", role: .destructive) { }
            }

            Menu("Scales Bluetooth") {
                Button("Pair Device") { }
                Button("Forget Device", role: .destructive) { }
            }

            Menu("Door 1 Bluetooth") {
                Button("Pair Device") { }
                Button("Forget Device", role: .destructive) { }
            }

            Menu("Door 2 Bluetooth") {
                Button("Pair Device") { }
                Button("Forget Device", role: .destructive) { }
            }
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.title3.weight(.semibold))
                .symbolRenderingMode(.hierarchical)
        }
    }

    private var tipperSection: some View {
        GlassPanel(title: "Tipper") {
            HStack(spacing: 18) {
                MomentaryButton(
                    symbol: "arrow.up.circle.fill",
                    title: "Up",
                    tint: .green,
                    isPressed: $tipperIsPressedUp
                )

                MomentaryButton(
                    symbol: "arrow.down.circle.fill",
                    title: "Down",
                    tint: .orange,
                    isPressed: $tipperIsPressedDown
                )
            }
        }
    }

    private var tarpSection: some View {
        GlassPanel(title: "Tarp") {
            HStack(spacing: 18) {
                ToggleDirectionButton(
                    symbol: "arrow.left.circle.fill",
                    title: "Off",
                    tint: .red,
                    isActive: tarpDirection == .left
                ) {
                    tarpDirection = .left
                }

                ToggleDirectionButton(
                    symbol: "arrow.right.circle.fill",
                    title: "On",
                    tint: .blue,
                    isActive: tarpDirection == .right
                ) {
                    tarpDirection = .right
                }
            }
        }
    }

    private var scalesSection: some View {
        GlassPanel(title: "Scales") {
            HStack(alignment: .center) {
                Text(String(format: "%06.3f", max(0, min(weightValue, 99.999))))
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .minimumScaleFactor(0.7)

                Button("Tare") {
                    weightValue = 0
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
    }

    private var doorsSection: some View {
        HStack(spacing: 12) {
            DoorControlView(title: "Door 1", state: $door1State)
            DoorControlView(title: "Door 2", state: $door2State)
        }
    }
}

private enum TarpDirection {
    case left
    case right
    case stopped
}

private enum DoorDirection {
    case up
    case down
    case idle
}

private struct GlassPanel<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)

            content
                .frame(maxWidth: .infinity)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 10, y: 3)
    }
}

private struct MomentaryButton: View {
    let symbol: String
    let title: String
    let tint: Color
    @Binding var isPressed: Bool

    var body: some View {
        ImageLabelButton(symbol: symbol, title: title, tint: tint, isActive: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
            .accessibilityAddTraits(.isButton)
    }
}

private struct ToggleDirectionButton: View {
    let symbol: String
    let title: String
    let tint: Color
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ImageLabelButton(symbol: symbol, title: title, tint: tint, isActive: isActive)
        }
        .buttonStyle(.plain)
    }
}

private struct ImageLabelButton: View {
    let symbol: String
    let title: String
    let tint: Color
    let isActive: Bool

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 46, weight: .bold))
            Text(title)
                .font(.title3.weight(.semibold))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 6)
        .foregroundStyle(isActive ? .white : tint)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(isActive ? tint : tint.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(tint.opacity(0.3), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.12), value: isActive)
    }
}

private struct DoorControlView: View {
    let title: String
    @Binding var state: DoorDirection

    var body: some View {
        GlassPanel(title: title) {
            VStack(spacing: 12) {
                MomentaryDoorButton(
                    symbol: "arrow.up.circle.fill",
                    title: "Open",
                    tint: .green,
                    isPressed: state == .up
                ) {
                    state = .up
                } onRelease: {
                    state = .idle
                }

                MomentaryDoorButton(
                    symbol: "arrow.down.circle.fill",
                    title: "Close",
                    tint: .orange,
                    isPressed: state == .down
                ) {
                    state = .down
                } onRelease: {
                    state = .idle
                }
            }
        }
    }
}

private struct MomentaryDoorButton: View {
    let symbol: String
    let title: String
    let tint: Color
    let isPressed: Bool
    let onPress: () -> Void
    let onRelease: () -> Void

    var body: some View {
        ImageLabelButton(symbol: symbol, title: title, tint: tint, isActive: isPressed)
            .frame(maxHeight: .infinity)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
            .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    ContentView()
}
