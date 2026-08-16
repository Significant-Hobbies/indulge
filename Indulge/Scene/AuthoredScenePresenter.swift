import SwiftUI
import UIKit

enum AuthoredSceneContentMode: Equatable, Sendable {
  case fill
  case fit
}

struct AuthoredSceneMotionPlan: Equatable, Sendable {
  let breathingScale: CGFloat
  let parallax: CGFloat
  let lightDriftOpacity: Double
  let runsAmbientLoops: Bool
  let transitionDuration: TimeInterval

  static func resolve(reduceMotion: Bool, ambientMotion: Bool) -> Self {
    guard !reduceMotion, ambientMotion else {
      return Self(
        breathingScale: 1,
        parallax: 0,
        lightDriftOpacity: 0,
        runsAmbientLoops: false,
        transitionDuration: 0.18
      )
    }
    return Self(
      breathingScale: 1.018,
      parallax: 5,
      lightDriftOpacity: 0.34,
      runsAmbientLoops: true,
      transitionDuration: 0.42
    )
  }
}

extension OnboardingVisualState {
  var semanticSummary: String {
    switch self {
    case .standing:
      "A character stands in a quiet room."
    case .watchingTelevision(let phone, let drink):
      [
        "A character sits on a sofa watching television",
        phone ? "holding a phone" : nil,
        drink ? "holding a drink" : nil,
      ]
      .compactMap { $0 }
      .joined(separator: ", ") + "."
    case .scrolling:
      "A standing character holds a phone and scrolls."
    case .browsing:
      "A character sits at a desk and browses on a laptop."
    case .gaming:
      "A character sits forward on a sofa and plays with a controller."
    case .listening:
      "A seated character relaxes with headphones and music."
    case .taste:
      "A character sits at a table with snacks, takeaway, something sweet, and coffee."
    case .rest:
      "A character rests peacefully under a blanket."
    case .social:
      "A character smiles and waves during a video call."
    }
  }
}

struct AuthoredScenePresenter: View {
  @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
  let assetName: String
  let contentMode: AuthoredSceneContentMode
  let alignment: Alignment
  let semanticLabel: String
  let ambientMotion: Bool
  let reduceMotionOverride: Bool?

  @State private var breathes = false
  @State private var lightTravels = false

  init(
    assetName: String,
    contentMode: AuthoredSceneContentMode = .fill,
    alignment: Alignment = .center,
    semanticLabel: String,
    ambientMotion: Bool = true,
    reduceMotionOverride: Bool? = nil
  ) {
    self.assetName = assetName
    self.contentMode = contentMode
    self.alignment = alignment
    self.semanticLabel = semanticLabel
    self.ambientMotion = ambientMotion
    self.reduceMotionOverride = reduceMotionOverride
  }

  var body: some View {
    GeometryReader { proxy in
      ZStack {
        renderedImage
          .frame(width: proxy.size.width, height: proxy.size.height, alignment: alignment)
          .scaleEffect(breathes ? motionPlan.breathingScale : 1)
          .offset(x: breathes ? motionPlan.parallax : -motionPlan.parallax)

        LinearGradient(
          colors: [.clear, .white.opacity(0.22), .clear],
          startPoint: .leading,
          endPoint: .trailing
        )
        .blendMode(.softLight)
        .offset(x: lightTravels ? proxy.size.width : -proxy.size.width)
        .opacity(motionPlan.lightDriftOpacity)
        .accessibilityHidden(true)
      }
      .frame(width: proxy.size.width, height: proxy.size.height)
      .clipped()
    }
    .id(assetName)
    .transition(.opacity)
    .animation(.easeInOut(duration: motionPlan.transitionDuration), value: assetName)
    .task(id: motionTaskID) {
      breathes = false
      lightTravels = false
      guard motionPlan.runsAmbientLoops else { return }
      withAnimation(.easeInOut(duration: 4.6).repeatForever(autoreverses: true)) {
        breathes = true
      }
      withAnimation(.linear(duration: 8.2).repeatForever(autoreverses: false)) {
        lightTravels = true
      }
    }
    .onDisappear {
      breathes = false
      lightTravels = false
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(semanticLabel)
  }

  private var reduceMotion: Bool {
    reduceMotionOverride ?? systemReduceMotion
  }

  private var motionPlan: AuthoredSceneMotionPlan {
    .resolve(reduceMotion: reduceMotion, ambientMotion: ambientMotion)
  }

  private var motionTaskID: String {
    "\(assetName)-\(reduceMotion)-\(ambientMotion)"
  }

  @ViewBuilder
  private var renderedImage: some View {
    if let source = UIImage(named: assetName, in: .main, compatibleWith: nil) {
      let image = Image(uiImage: source).resizable()
      if contentMode == .fill {
        image.scaledToFill()
      } else {
        image.scaledToFit()
      }
    } else {
      Color.indulgePowder
        .overlay {
          Image(systemName: "photo")
            .foregroundStyle(Color.indulgeText.opacity(0.35))
        }
    }
  }
}
