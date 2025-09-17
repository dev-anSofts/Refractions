//
//  ContentView.swift
//  Refractions
//
//  Created by Anthony Alessio Tralongo on 16/09/25.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

struct ContentView: View {
    // Hardcoded topics for the app's catalog
    private let topics: [String] = [
        "Basics",
        "Glass Effect Basics",
        "Tint & Legibility",
        "Interactions",
        "Transitions & Morphing",
        "Shapes & Morphing",
        "SwiftUI & Containers",
        "Performance & Composition",
        "Widgets",
        "Platform Variants: UIKit & AppKit",
        "Accessibility & Legibility",
        "Motion & Responsiveness"
    ]

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 12) {
                // Liquid Glass header above the list
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        HStack(spacing: 12) {
                            Image(systemName: "drop.halffull")
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 2) {
#if os(iOS)
                                Text("Refractions")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
#elseif os(macOS)
                                Text("LiquidGlass Guide")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
#endif
                              /*  Text("Topics Catalog")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)*/
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(14)
                    )
                    .frame(maxWidth: .infinity)
    #if os(iOS)
                    .frame(height: 88)
    #else
                    .frame(height: 72)
    #endif
                    .padding(.horizontal)
                    .padding(.top)

                // Static, hardcoded list (no SwiftData, no toolbar)
                List(topics, id: \.self) { topic in
                    NavigationLink(topic) {
                        TopicRouterView(topic: topic)
                    }
                }
    #if os(macOS)
                .navigationSplitViewColumnWidth(min: 180, ideal: 240)
                .listStyle(.inset)
    #endif
    #if os(iOS)
                .listStyle(.insetGrouped)
    #endif
            }
        } detail: {
            TopicDetailPlaceholder()
        }
    }
}

// MARK: - Detail placeholders

private struct TopicDetailPlaceholder: View {
    var body: some View {
        #if os(iOS)
        Text("Select a topic")
            .font(.title3)
            .foregroundStyle(.secondary)
            .navigationTitle("Liquid Glass")
        #else
        Text("Select a topic")
            .font(.title3)
            .foregroundStyle(.secondary)
        #endif
    }
}

// MARK: - Topic Router

private struct TopicRouterView: View {
    let topic: String

    var body: some View {
        switch topic {
        case "Basics": BasicsDemo()
        case "Glass Effect Basics": GlassEffectsDemo()
        case "Tint & Legibility": MaterialsTintingDemo()
        case "Interactions": InteractionsDemo()
        case "Transitions & Morphing": TransitionsDemo()
        case "Shapes & Morphing": ShapesMorphingDemo()
        case "SwiftUI & Containers": SwiftUIContainersDemo()
        case "Performance & Composition": PerformanceCompositionDemo()
        case "Widgets": WidgetsDemo()
        case "Platform Variants: UIKit & AppKit": PlatformVariantsDemo()
        case "Accessibility & Legibility": AccessibilityLegibilityDemo()
        case "Motion & Responsiveness": MotionResponsivenessDemo()
        default: TopicDetailView(title: topic)
        }
    }
}

// MARK: - Topic Detail (Fallback)

private struct TopicDetailView: View {
    let title: String

    var body: some View {
        DemoContainer(title: title) {
            GlassCard(title: title, subtitle: "Custom topic", cornerRadius: 24)
                .frame(height: 160)
        } code: {
            CodeBlock(code: """
            // Fallback detail view for unknown topics
            // This view is shown when a topic doesn't have a dedicated demo yet.
            """)
        }
        #if os(iOS)
        .navigationTitle(title)
        #endif
    }
}

// MARK: - Shared helpers

// Small, glass-styled button
private struct GlassButton: View {
    enum Size { case small, medium }
    enum Style { case glass, glassProminent }
    var systemName: String
    var tint: Color = .blue.opacity(0.35)
    var size: Size = .small
    var cornerRadius: CGFloat = 12
    var style: Style = .glass
    var action: () -> Void

    private var dimension: CGFloat { size == .small ? 40 : 52 }
    private var corner: CGFloat { size == .small ? 12 : 16 }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size == .small ? 16 : 20, weight: .semibold))
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .frame(width: dimension, height: dimension)
        .glass(cornerRadius: cornerRadius, tint: tint.opacity(style == .glassProminent ? 0.5 : 0.35))
    }
}

// A small button row to preview multiple actions
private struct GlassButtonRow: View {
    var tint: Color = .blue.opacity(0.35)
    var actionSettings: () -> Void
    var actionInfo: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            GlassButton(systemName: "gearshape.fill", tint: tint, size: .small, cornerRadius: 12, style: .glass, action: actionSettings)
            GlassButton(systemName: "info.circle.fill", tint: tint, size: .small, cornerRadius: 12, style: .glass, action: actionInfo)
            GlassButton(systemName: "slider.horizontal.3", tint: tint, size: .small, cornerRadius: 12, style: .glass, action: actionSettings)
        }
    }
}

// MARK: - Glass Effect APIs

private struct GlassEffectContainer<Content: View>: View {
    let cornerRadius: CGFloat
    let tint: Color
    @ViewBuilder var content: () -> Content

    init(cornerRadius: CGFloat = 24, tint: Color = .blue.opacity(0.35), @ViewBuilder content: @escaping () -> Content) {
        self.cornerRadius = cornerRadius
        self.tint = tint
        self.content = content
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(tint)
                        .blendMode(.plusLighter)
                        .opacity(0.65)
                )
            content()
                .padding()
        }
    }
}

private enum GlassEffectStyle {
    case interactive
}

private struct GlassInteractiveEffect: ViewModifier {
    @GestureState private var isPressing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressing ? 0.98 : 1)
            .shadow(color: .black.opacity(isPressing ? 0.15 : 0.25), radius: isPressing ? 10 : 20, x: 0, y: isPressing ? 6 : 12)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isPressing)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($isPressing) { _, state, _ in state = true }
            )
    }
}

private struct GlassBaseStyle: ViewModifier {
    var cornerRadius: CGFloat = 24
    var tint: Color = .blue.opacity(0.35)

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(tint)
                            .blendMode(.plusLighter)
                            .opacity(0.65)
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

private extension View {
    func glass(cornerRadius: CGFloat = 24, tint: Color = .blue.opacity(0.35)) -> some View {
        modifier(GlassBaseStyle(cornerRadius: cornerRadius, tint: tint))
    }

    func glassEffect(_ style: GlassEffectStyle) -> some View {
        switch style {
        case .interactive:
            return AnyView(modifier(GlassInteractiveEffect()))
        }
    }
}

// MARK: - Glass Effects Demo

private struct GlassEffectsDemo: View {
    @State private var tint = Color.purple.opacity(0.35)
    @State private var corner: CGFloat = 24

    var body: some View {
        DemoContainer(title: "Glass Effects") {
            VStack(spacing: 16) {
                GlassEffectContainer(cornerRadius: corner, tint: tint) {
                    VStack(spacing: 8) {
                        Text("GlassEffectContainer")
                            .font(.headline)
                        Text("Container + tint + material")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(height: 160)
                .glassEffect(.interactive)
                HStack(spacing: 12) {
                    GlassButton(systemName: "gearshape.fill", tint: tint, size: .small, cornerRadius: max(10, min(corner/2, 16)), style: .glassProminent) { print("GlassEffects: gear tapped") }
                    GlassButton(systemName: "info.circle.fill", tint: tint, size: .small, cornerRadius: max(10, min(corner/2, 16)), style: .glassProminent) { print("GlassEffects: info tapped") }
                    GlassButton(systemName: "questionmark.circle.fill", tint: tint, size: .small, cornerRadius: max(10, min(corner/2, 16)), style: .glassProminent) { print("GlassEffects: help tapped") }
                }

                VStack(spacing: 8) {
                    Text(".glass style")
                        .font(.headline)
                    Text("Apply as a modifier")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .glass(cornerRadius: corner, tint: tint)
                .glassEffect(.interactive)

                VStack(alignment: .leading) {
                    LabeledContent("Corner Radius") {
                        Slider(value: Binding(get: { Double(corner) }, set: { corner = CGFloat($0) }), in: 12...40)
                            .frame(width: 160)
                    }
                    LabeledContent("Tint Color") {
                        ColorPicker("", selection: $tint, supportsOpacity: true)
                            .labelsHidden()
                            .frame(width: 160)
                    }
                }
            }
        } code: {
            CodeBlock(code: """
            // Container usage
            GlassEffectContainer(cornerRadius: 24, tint: .blue.opacity(0.35)) {
                Text("Content")
            }
            .glassEffect(.interactive)

            // Small glass buttons
            HStack(spacing: 12) {
                Button(action: { /* gear */ }) { Image(systemName: "gearshape.fill") }
                Button(action: { /* info */ }) { Image(systemName: "info.circle.fill") }
                Button(action: { /* help */ }) { Image(systemName: "questionmark.circle.fill") }
            }
            .modifier(GlassBaseStyle(cornerRadius: 12, tint: .blue.opacity(0.35)))

            // Style usage
            Text("Content")
                .glass(cornerRadius: 24, tint: .blue.opacity(0.35))
                .glassEffect(.interactive)
            """)
        }
    }
}

private struct CodeTextPreferenceKey: PreferenceKey {
    static var defaultValue: String = ""
    static func reduce(value: inout String, nextValue: () -> String) {
        value = nextValue()
    }
}

private struct CodeBlock: View {
    let code: String

    var body: some View {
        ScrollView(.horizontal) {
            Text(code)
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.thinMaterial)
                )
                .preference(key: CodeTextPreferenceKey.self, value: code)
        }
    }
}

private struct GlassCard: View {
    var title: String = "Liquid Glass Card"
    var subtitle: String = "Material + tint + shape"
    var cornerRadius: CGFloat = 24
    var tint: Color = .blue.opacity(0.35)
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(tint)
                    .blendMode(.plusLighter)
                    .opacity(0.65)
            )
            .overlay(
                VStack(spacing: 8) {
                    Text(title).font(.headline)
                    Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
                }
                .padding()
            )
    }
}

// MARK: - Basics

private struct BasicsDemo: View {
    var body: some View {
        DemoContainer(title: "Basics") {
            GlassCard()
                .frame(height: 180)
            VStack(alignment: .leading, spacing: 8) {
                Text("Live Preview")
                    .font(.headline)
                GlassButtonRow(tint: .blue.opacity(0.35), actionSettings: { print("Basics: settings tapped") }, actionInfo: { print("Basics: info tapped") })
            }
        } code: {
            CodeBlock(code: """
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.blue.opacity(0.35))
                        .blendMode(.plusLighter)
                        .opacity(0.65)
                )
                .frame(height: 180)

            // Small glass buttons
            HStack(spacing: 12) {
                Button(action: { /* settings */ }) { Image(systemName: "gearshape.fill") }
                Button(action: { /* info */ }) { Image(systemName: "info.circle.fill") }
            }
            .modifier(GlassBaseStyle(cornerRadius: 12, tint: .blue.opacity(0.35)))
            """)
        }
    }
}

// MARK: - Interactions

private struct InteractionsDemo: View {
    @State private var isPressed = false
    var body: some View {
        DemoContainer(title: "Interactions") {
            HStack(spacing: 16) {
                GlassButton(systemName: "gearshape.fill", tint: .blue.opacity(0.35), size: .small, cornerRadius: 12, style: .glassProminent) { isPressed.toggle() }
                    .scaleEffect(isPressed ? 0.96 : 1)
                    .shadow(color: .black.opacity(isPressed ? 0.15 : 0.25), radius: isPressed ? 10 : 20, x: 0, y: isPressed ? 6 : 12)
                GlassButton(systemName: "info.circle.fill", tint: .purple.opacity(0.35), size: .small, cornerRadius: 12, style: .glassProminent) { isPressed.toggle() }
                    .scaleEffect(isPressed ? 0.96 : 1)
                    .shadow(color: .black.opacity(isPressed ? 0.15 : 0.25), radius: isPressed ? 10 : 20, x: 0, y: isPressed ? 6 : 12)
                GlassButton(systemName: "slider.horizontal.3", tint: .mint.opacity(0.35), size: .small, cornerRadius: 12, style: .glassProminent) { isPressed.toggle() }
                    .scaleEffect(isPressed ? 0.96 : 1)
                    .shadow(color: .black.opacity(isPressed ? 0.15 : 0.25), radius: isPressed ? 10 : 20, x: 0, y: isPressed ? 6 : 12)
            }
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
        } code: {
            CodeBlock(code: """
            @State private var isPressed = false

            HStack(spacing: 16) {
                GlassButton(systemName: "gearshape.fill", tint: .blue.opacity(0.35), size: .small, cornerRadius: 12, style: .glassProminent) { isPressed.toggle() }
                    .scaleEffect(isPressed ? 0.96 : 1)
                    .shadow(color: .black.opacity(isPressed ? 0.15 : 0.25), radius: isPressed ? 10 : 20, x: 0, y: isPressed ? 6 : 12)
                GlassButton(systemName: "info.circle.fill", tint: .purple.opacity(0.35), size: .small, cornerRadius: 12, style: .glassProminent) { isPressed.toggle() }
                    .scaleEffect(isPressed ? 0.96 : 1)
                    .shadow(color: .black.opacity(isPressed ? 0.15 : 0.25), radius: isPressed ? 10 : 20, x: 0, y: isPressed ? 6 : 12)
                GlassButton(systemName: "slider.horizontal.3", tint: .mint.opacity(0.35), size: .small, cornerRadius: 12, style: .glassProminent) { isPressed.toggle() }
                    .scaleEffect(isPressed ? 0.96 : 1)
                    .shadow(color: .black.opacity(isPressed ? 0.15 : 0.25), radius: isPressed ? 10 : 20, x: 0, y: isPressed ? 6 : 12)
            }
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
            """)
        }
    }
}

// MARK: - Transitions

private struct TransitionsDemo: View {
    @Namespace private var ns
    @State private var expanded = false
    var body: some View {
        DemoContainer(title: "Transitions") {
            ZStack(alignment: .top) {
                if expanded {
                    GlassCard(title: "Expanded", subtitle: "Morphing shape", cornerRadius: 32)
                        .frame(height: 260)
                        .matchedGeometryEffect(id: "glass", in: ns)
                        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                } else {
                    GlassCard(title: "Collapsed", subtitle: "Tap to expand", cornerRadius: 20)
                        .frame(height: 140)
                        .matchedGeometryEffect(id: "glass", in: ns)
                        .transition(.opacity)
                }
            }
            .onTapGesture { withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { expanded.toggle() } }
        } code: {
            CodeBlock(code: """
            @Namespace private var ns
            @State private var expanded = false

            ZStack {
                if expanded {
                    GlassCard(cornerRadius: 32)
                        .frame(height: 260)
                        .matchedGeometryEffect(id: "glass", in: ns)
                } else {
                    GlassCard(cornerRadius: 20)
                        .frame(height: 140)
                        .matchedGeometryEffect(id: "glass", in: ns)
                }
            }
            .onTapGesture { withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { expanded.toggle() } }
            """)
        }
    }
}

// MARK: - Materials & Tinting

private struct MaterialsTintingDemo: View {
    @State private var tint = Color.blue.opacity(0.35)
    @State private var intensity: Double = 0.65

    var body: some View {
        DemoContainer(title: "Materials & Tinting") {
            GlassCard(subtitle: "Prefer subtle tint; keep text legible", tint: tint.opacity(intensity))
                .frame(height: 180)

            VStack(alignment: .leading) {
                LabeledContent("Tint Color") {
                    ColorPicker("", selection: $tint, supportsOpacity: true)
                        .labelsHidden()
                        .frame(width: 160)
                }
                LabeledContent("Intensity") {
                    Slider(value: $intensity, in: 0...1)
                        .frame(width: 160)
                }
            }
        } code: {
            CodeBlock(code: """
            @State private var tint = Color.blue.opacity(0.35)
            @State private var intensity: Double = 0.65

            GlassCard(tint: tint.opacity(intensity))
                .frame(height: 180)

            Slider(value: $intensity, in: 0...1)
            ColorPicker("Tint", selection: $tint, supportsOpacity: true)
            """)
        }
    }
}

// MARK: - Shapes & Morphing

private struct ShapesMorphingDemo: View {
    @State private var useCapsule = false
    var body: some View {
        DemoContainer(title: "Shapes & Morphing") {
            Group {
                if useCapsule {
                    Capsule(style: .circular)
                        .fill(.ultraThinMaterial)
                        .overlay(Capsule().strokeBorder(.white.opacity(0.15)))
                        .frame(height: 120)
                        .transition(.opacity)
                } else {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).strokeBorder(.white.opacity(0.15)))
                        .frame(height: 180)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: useCapsule)
            .onTapGesture { useCapsule.toggle() }
        } code: {
            CodeBlock(code: """
            @State private var useCapsule = false

            Group {
                if useCapsule {
                    Capsule().fill(.ultraThinMaterial)
                } else {
                    RoundedRectangle(cornerRadius: 28).fill(.ultraThinMaterial)
                }
            }
            .onTapGesture { useCapsule.toggle() }
            """)
        }
    }
}

// MARK: - SwiftUI & Containers

private struct SwiftUIContainersDemo: View {
    @Namespace private var ns
    @State private var spacing: Double = 40
    @State private var mergeToggle = true

    var body: some View {
        DemoContainer(title: "SwiftUI & Containers") {
            VStack(alignment: .leading, spacing: 16) {
                GlassEffectContainer(cornerRadius: 24, tint: .blue.opacity(0.25)) {
                    HStack(spacing: spacing) {
                        Image(systemName: "scribble.variable")
                            .font(.system(size: 36))
                            .frame(width: 80, height: 80)
                            .glass(cornerRadius: 20, tint: .blue.opacity(0.25))
                            .glassEffect(.interactive)
                            .overlay(Text("A").font(.caption).padding(4), alignment: .bottomTrailing)

                        Image(systemName: "eraser.fill")
                            .font(.system(size: 36))
                            .frame(width: 80, height: 80)
                            .glass(cornerRadius: 20, tint: .purple.opacity(0.25))
                            .glassEffect(.interactive)
                            .overlay(Text("B").font(.caption).padding(4), alignment: .bottomTrailing)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 160)

                VStack(alignment: .leading) {
                    LabeledContent("Spacing") {
                        Slider(value: $spacing, in: 0...80)
                            .frame(width: 200)
                    }
                    Toggle("Merge group (union)", isOn: $mergeToggle)
                }
            }
        } code: {
            CodeBlock(code: """
            // Use a container to improve performance and enable merging
            GlassEffectContainer(spacing: 40) {
                HStack(spacing: 40) {
                    Image(systemName: "scribble.variable")
                        .glassEffect()
                        .glassEffectID("pencil", in: ns)
                    Image(systemName: "eraser.fill")
                        .glassEffect()
                        .glassEffectID("eraser", in: ns)
                }
            }
            """)
        }
    }
}

// MARK: - Performance & Composition

private struct PerformanceCompositionDemo: View {
    @State private var spacing: Double = 32
    @State private var count: Int = 3

    var body: some View {
        DemoContainer(title: "Performance & Composition") {
            VStack(alignment: .leading, spacing: 16) {
                GlassEffectContainer(cornerRadius: 24, tint: .blue.opacity(0.2)) {
                    HStack(spacing: spacing) {
                        ForEach(0..<count, id: \.self) { idx in
                            Image(systemName: idx % 2 == 0 ? "circle.fill" : "square.fill")
                                .font(.system(size: 28))
                                .frame(width: 64, height: 64)
                                .glass(cornerRadius: 16, tint: .blue.opacity(0.25))
                        }
                    }
                }
                .frame(height: 140)

                VStack(alignment: .leading) {
                    LabeledContent("Spacing") {
                        Slider(value: $spacing, in: 0...80)
                            .frame(width: 200)
                    }
                    LabeledContent("Effect Count") {
                        Stepper(value: $count, in: 1...6) { Text("\(count)") }
                            .frame(width: 200)
                    }
                    Text("Tip: Use containers to merge nearby effects, reduce passes, and limit the number of simultaneous glass elements.")
                        .foregroundStyle(.secondary)
                }
            }
        } code: {
            CodeBlock(code: """
            // Keep effect count reasonable and use containers for groups
            GlassEffectContainer(spacing: 32) {
                HStack(spacing: 32) {
                    // elements
                }
            }
            """)
        }
    }
}

// MARK: - Platform Variants

private struct PlatformVariantsDemo: View {
    var body: some View {
        DemoContainer(title: "Platform Variants") {
            #if os(iOS)
            GlassCard(title: "iOS Variant", subtitle: "Inset grouped list style")
                .frame(height: 160)
            #elseif os(macOS)
            GlassCard(title: "macOS Variant", subtitle: "Inset list & column width")
                .frame(height: 160)
            #endif
        } code: {
            CodeBlock(code: """
            #if os(iOS)
            // iOS-specific styling
            .listStyle(.insetGrouped)
            #else
            // macOS-specific styling
            .navigationSplitViewColumnWidth(min: 180, ideal: 240)
            .listStyle(.inset)
            #endif
            """)
        }
    }
}

// MARK: - Widgets

private struct WidgetsDemo: View {
    var body: some View {
        DemoContainer(title: "Widgets") {
            GlassCard(title: "Widget Look", subtitle: "Use materials sparingly")
                .frame(height: 140)
            HStack(spacing: 12) {
                GlassButton(systemName: "gearshape", tint: .gray.opacity(0.25), size: .small, cornerRadius: 10, style: .glass) {}
                GlassButton(systemName: "info.circle", tint: .gray.opacity(0.25), size: .small, cornerRadius: 10, style: .glass) {}
            }
            Text("Widgets respect rendering modes; prefer system backgrounds, subtle tints, and avoid heavy blur.")
                .foregroundStyle(.secondary)
        } code: {
            CodeBlock(code: """
            // Detect widget rendering mode
            @Environment(\\.widgetRenderingMode) var mode

            if mode == .accented {
                // Layout optimized for accented mode
            } else {
                // Full color layout
            }

            // Group primary/accent content
            Text("Title").widgetAccentable()
            Image(systemName: "star.fill").widgetAccentable()

            // Configure backgrounds and visionOS texture in Widget configuration
            // .containerBackgroundRemovable(false)
            // .widgetTexture(.glass)
            """)
        }
    }
}

// MARK: - Accessibility & Legibility

private struct AccessibilityLegibilityDemo: View {
    @Environment(\.colorScheme) private var scheme
    @State private var tint = Color.blue.opacity(0.35)
    @State private var contrastBoost = false

    var body: some View {
        DemoContainer(title: "Accessibility & Legibility") {
            VStack(alignment: .leading, spacing: 12) {
                GlassCard(title: "Readable Content", subtitle: "Ensure sufficient contrast", tint: tint)
                    .frame(height: 140)
                    .overlay(
                        Text("Aa")
                            .font(.system(size: 36, weight: .semibold, design: .rounded))
                            .padding(16)
                    )

                Toggle("Boost contrast for readability", isOn: $contrastBoost)
                    .onChange(of: contrastBoost) { _, newValue in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            tint = newValue ? Color.blue.opacity(0.45) : Color.blue.opacity(0.35)
                        }
                    }

                Text("Tips: Keep blur subtle, avoid busy backgrounds behind text, and test with Differentiate Without Color / Increase Contrast.")
                    .foregroundStyle(.secondary)
            }
        } code: {
            CodeBlock(code: """
            // Keep tints subtle and ensure text contrast
            Text("Title")
                .font(.headline)
                .foregroundStyle(.primary)
                .padding()
                .glass(cornerRadius: 16, tint: .blue.opacity(0.35))
            """)
        }
    }
}

// MARK: - Motion & Responsiveness

private struct MotionResponsivenessDemo: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPressed = false

    var body: some View {
        DemoContainer(title: "Motion & Responsiveness") {
            HStack(spacing: 16) {
                GlassButton(systemName: "gearshape.fill", tint: .blue.opacity(0.35), size: .small, cornerRadius: 12, style: .glass) { isPressed.toggle() }
                GlassButton(systemName: "info.circle.fill", tint: .purple.opacity(0.35), size: .small, cornerRadius: 12, style: .glass) { isPressed.toggle() }
                GlassButton(systemName: "questionmark.circle.fill", tint: .mint.opacity(0.35), size: .small, cornerRadius: 12, style: .glass) { isPressed.toggle() }
            }
            .scaleEffect(isPressed ? 0.97 : 1)
            .animation(reduceMotion ? .none : .spring(response: 0.25, dampingFraction: 0.85), value: isPressed)

            Text("Respect Reduce Motion and avoid excessive parallax or bouncy effects.")
                .foregroundStyle(.secondary)
        } code: {
            CodeBlock(code: """
            @Environment(\\.accessibilityReduceMotion) var reduceMotion

            // Use spring animations sparingly and respect Reduce Motion
            withAnimation(reduceMotion ? .none : .spring(response: 0.25, dampingFraction: 0.85)) {
                // state change
            }
            """)
        }
    }
}

// MARK: - Shared demo container

private struct DemoContainer<Demo: View, Code: View>: View {
    let title: String
    @ViewBuilder var demo: () -> Demo
    @ViewBuilder var code: () -> Code
    @State private var currentCode: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.largeTitle.bold())

                demo()

                HStack(alignment: .center, spacing: 8) {
                    Text("Code Snippet")
                        .font(.headline)
                    Spacer(minLength: 8)
#if os(macOS)
                    GlassButton(systemName: "document.on.document", tint: .gray.opacity(0.25), size: .small, cornerRadius: 10, style: .glass) {
                        #if os(macOS)
                        let pb = NSPasteboard.general
                        pb.clearContents()
                        pb.setString(currentCode, forType: .string)
                        #endif
                    }
#elseif os(iOS)
                    GlassButton(systemName: "document.on.document", tint: .gray.opacity(0.25), size: .small, cornerRadius: 10, style: .glass) {
                        #if os(iOS)
                        UIPasteboard.general.string = currentCode
                        #endif
                    }
#endif
                }
                // Platform availability reference
#if os(iOS)
                Text("Copy and Paste from macOS and iPadOS for a better experience")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
#endif
                code()
            }
            .padding()
            .onPreferenceChange(CodeTextPreferenceKey.self) { value in
                currentCode = value
            }
        }
    }
}
#Preview {
    ContentView()
}

