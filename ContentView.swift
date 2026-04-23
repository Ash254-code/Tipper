import SwiftUI

struct ContentView: View {
    @State private var tipperUpPressed = false
    @State private var tipperDownPressed = false

    @State private var tarpDirection: TarpDirection = .stopped

    @State private var scaleReading: Double = 0

    @State private var door1Direction: DoorDirection = .idle
    @State private var door2Direction: DoorDirection = .idle

    var body: some View {
        GeometryReader { proxy in
            let section = max(proxy.size.height / 5, 120)

            ZStack {
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 10) {
                    header

                    GlassPanel(title: "Tipper") {
                        HStack(spacing: 14) {
                            MomentaryButton(symbol: "arrow.up.circle.fill", title: "Up", tint: .green, isPressed: $tipperUpPressed)
                            MomentaryButton(symbol: "arrow.down.circle.fill", title: "Down", tint: .orange, isPressed: $tipperDownPressed)
                        }
                    }
                    .frame(height: section)

                    GlassPanel(title: "Tarp") {
                        HStack(spacing: 14) {
                            ToggleDirectionButton(symbol: "arrow.left.circle.fill", title: "off", tint: .red, isActive: tarpDirection == .off) {
                                tarpDirection = .off
                            }

                            ToggleDirectionButton(symbol: "arrow.right.circle.fill", title: "on", tint: .blue, isActive: tarpDirection == .on) {
                                tarpDirection = .on
                            }
                        }
                    }
                    .frame(height: section)

                    GlassPanel(title: "Scales") {
                        HStack(spacing: 12) {
                            Text(String(format: "%06.3f", min(max(scaleReading, 0), 99.999)))
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .lineLimit(1)
                                .minimumScaleFactor(0.65)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Button("Tare") {
                                scaleReading = 0
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                    }
                    .frame(height: section)

                    HStack(spacing: 10) {
                        DoorControlPanel(title: "Door 1", direction: $door1Direction)
                        DoorControlPanel(title: "Door 2", direction: $door2Direction)
                    }
                    .frame(height: section * 2)
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 10)
            }
        }
        .onAppear {
            tarpDirection = .stopped
        }
    }

    private var header: some View {
        HStack {
            Text("Tipper")
                .font(.largeTitle.weight(.bold))

            Spacer()

            Menu {
                bluetoothMenu(title: "Tipper")
                bluetoothMenu(title: "Tarp")
                bluetoothMenu(title: "Scales")
                bluetoothMenu(title: "Door 1")
                bluetoothMenu(title: "Door 2")
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title2.weight(.semibold))
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 2)
    }

    @ViewBuilder
    private func bluetoothMenu(title: String) -> some View {
        Menu("\(title) Bluetooth") {
            Button("Pair Device") {}
            Button("Forget Device", role: .destructive) {}
        }
    }
}

private enum TarpDirection {
    case off
    case on
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
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.22), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
    }
}

private struct ImageLabelButton: View {
    let symbol: String
    let title: String
    let tint: Color
    let active: Bool

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 44, weight: .bold))
            Text(title)
                .font(.title3.weight(.semibold))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(active ? .white : tint)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(active ? tint : tint.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(tint.opacity(0.35), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.12), value: active)
    }
}

private struct MomentaryButton: View {
    let symbol: String
    let title: String
    let tint: Color
    @Binding var isPressed: Bool

    var body: some View {
        ImageLabelButton(symbol: symbol, title: title, tint: tint, active: isPressed)
            .contentShape(Rectangle())
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
            ImageLabelButton(symbol: symbol, title: title, tint: tint, active: isActive)
        }
        .buttonStyle(.plain)
    }
}

private struct DoorControlPanel: View {
    let title: String
    @Binding var direction: DoorDirection

    var body: some View {
        GlassPanel(title: title) {
            VStack(spacing: 10) {
                DoorMomentaryButton(symbol: "arrow.up.circle.fill", title: "Open", tint: .green, active: direction == .up) {
                    direction = .up
                } onRelease: {
                    direction = .idle
                }

                DoorMomentaryButton(symbol: "arrow.down.circle.fill", title: "Close", tint: .orange, active: direction == .down) {
                    direction = .down
                } onRelease: {
                    direction = .idle
                }
            }
        }
    }
}

private struct DoorMomentaryButton: View {
    let symbol: String
    let title: String
    let tint: Color
    let active: Bool
    let onPress: () -> Void
    let onRelease: () -> Void

    var body: some View {
        ImageLabelButton(symbol: symbol, title: title, tint: tint, active: active)
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
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
