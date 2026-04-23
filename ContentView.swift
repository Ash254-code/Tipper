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
            let unit = max((proxy.size.height - 40) / 5, 1)

            ZStack(alignment: .topTrailing) {
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 8) {
                    tipperSection
                        .frame(height: unit)

                    tarpSection
                        .frame(height: unit)

                    scalesSection
                        .frame(height: unit)

                    HStack(spacing: 8) {
                        doorSection(title: "Door 1", direction: $door1Direction)
                        doorSection(title: "Door 2", direction: $door2Direction)
                    }
                    .frame(height: unit * 2)
                }
                .padding(10)

                settingsButton
                    .padding(.top, 12)
                    .padding(.trailing, 12)
            }
        }
        .onAppear {
            tarpDirection = .stopped
        }
    }

    private var settingsButton: some View {
        Menu {
            bluetoothMenu("Tipper")
            bluetoothMenu("Tarp")
            bluetoothMenu("Scales")
            bluetoothMenu("Door 1")
            bluetoothMenu("Door 2")
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.title3.weight(.semibold))
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial, in: Circle())
        }
    }

    @ViewBuilder
    private func bluetoothMenu(_ name: String) -> some View {
        Menu("\(name) Bluetooth") {
            Button("Pair Device") { }
            Button("Forget Device", role: .destructive) { }
        }
    }

    private var tipperSection: some View {
        GlassPanel(title: "Tipper") {
            HStack(spacing: 12) {
                MomentaryButton(symbol: "arrow.up.circle.fill", title: "Up", tint: .green, pressed: $tipperUpPressed)
                MomentaryButton(symbol: "arrow.down.circle.fill", title: "Down", tint: .orange, pressed: $tipperDownPressed)
            }
        }
    }

    private var tarpSection: some View {
        GlassPanel(title: "Tarp") {
            HStack(spacing: 12) {
                SelectButton(symbol: "arrow.left.circle.fill", title: "off", tint: .red, active: tarpDirection == .off) {
                    tarpDirection = .off
                }
                SelectButton(symbol: "arrow.right.circle.fill", title: "on", tint: .blue, active: tarpDirection == .on) {
                    tarpDirection = .on
                }
            }
        }
    }

    private var scalesSection: some View {
        GlassPanel(title: "Scales") {
            HStack {
                Text(String(format: "%06.3f", min(max(scaleReading, 0), 99.999)))
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                Spacer(minLength: 8)

                Button("Tare") { scaleReading = 0 }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
            }
        }
    }

    private func doorSection(title: String, direction: Binding<DoorDirection>) -> some View {
        GlassPanel(title: title) {
            VStack(spacing: 10) {
                MomentaryDoorButton(symbol: "arrow.up.circle.fill", title: "Open", tint: .green, active: direction.wrappedValue == .up) {
                    direction.wrappedValue = .up
                } onRelease: {
                    direction.wrappedValue = .idle
                }

                MomentaryDoorButton(symbol: "arrow.down.circle.fill", title: "Close", tint: .orange, active: direction.wrappedValue == .down) {
                    direction.wrappedValue = .down
                } onRelease: {
                    direction.wrappedValue = .idle
                }
            }
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
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
        )
    }
}

private struct ControlFace: View {
    let symbol: String
    let title: String
    let tint: Color
    let active: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.system(size: 42, weight: .bold))
            Text(title)
                .font(.title3.weight(.semibold))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(active ? .white : tint)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(active ? tint : tint.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(tint.opacity(0.35), lineWidth: 1)
        )
    }
}

private struct MomentaryButton: View {
    let symbol: String
    let title: String
    let tint: Color
    @Binding var pressed: Bool

    var body: some View {
        ControlFace(symbol: symbol, title: title, tint: tint, active: pressed)
            .contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in pressed = true }
                    .onEnded { _ in pressed = false }
            )
    }
}

private struct SelectButton: View {
    let symbol: String
    let title: String
    let tint: Color
    let active: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ControlFace(symbol: symbol, title: title, tint: tint, active: active)
        }
        .buttonStyle(.plain)
    }
}

private struct MomentaryDoorButton: View {
    let symbol: String
    let title: String
    let tint: Color
    let active: Bool
    let onPress: () -> Void
    let onRelease: () -> Void

    var body: some View {
        ControlFace(symbol: symbol, title: title, tint: tint, active: active)
            .contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}

#Preview {
    ContentView()
}
