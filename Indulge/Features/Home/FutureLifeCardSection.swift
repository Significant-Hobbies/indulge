import SwiftData
import SwiftUI

#if canImport(ImagePlayground)
  import ImagePlayground

  @available(iOS 18.1, *)
  struct FutureLifeCardSection: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.supportsImagePlayground) private var supportsImagePlayground
    @Query(sort: \FutureLifeCardRecord.createdAt, order: .reverse) private var cards:
      [FutureLifeCardRecord]

    let profile: OnboardingProfile
    @State private var presentsPlayground = false
    @State private var creationState = FutureLifeCardCreationState.idle
    @State private var confirmsDeletion = false
    @State private var errorMessage: String?
    @State private var retainedImage: UIImage?
    @State private var resolvedImageFileName: String?

    var body: some View {
      VStack(alignment: .leading, spacing: 14) {
        Label("A glimpse of what you’re making room for", systemImage: "photo.on.rectangle.angled")
          .font(.indulgeTitle)
          .foregroundStyle(Color.indulgeText)

        if let card = cards.first {
          if resolvedImageFileName != card.imageFileName {
            ProgressView("Loading saved card…")
              .frame(maxWidth: .infinity)
              .aspectRatio(1, contentMode: .fit)
          } else if let retainedImage {
            Image(uiImage: retainedImage)
              .resizable()
              .scaledToFill()
              .frame(maxWidth: .infinity)
              .aspectRatio(1, contentMode: .fit)
              .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
              .accessibilityLabel(
                "Future-life card for \(card.lifeDirections.map(\.title).sorted().joined(separator: ", "))"
              )

            if canCreate {
              Button("Create a new card", action: presentPlayground)
                .buttonStyle(.borderedProminent)
                .tint(Color.indulgeNavy)
            }
            Button("Delete card", role: .destructive) { confirmsDeletion = true }
          } else {
            Text(
              "The saved card image is unavailable. You can remove its saved record or create a replacement when Apple’s creation sheet is available."
            )
            .font(.indulgeBody)
            .foregroundStyle(Color.indulgeText.opacity(0.66))
            .fixedSize(horizontal: false, vertical: true)
            if canCreate {
              Button("Create a replacement", action: presentPlayground)
                .buttonStyle(.borderedProminent)
                .tint(Color.indulgeNavy)
            }
            Button("Remove unavailable card", role: .destructive) {
              confirmsDeletion = true
            }
          }
        } else if canCreate {
          Text(
            "Use Apple’s creation sheet to make one optional keepsake from the directions you chose."
          )
          .font(.indulgeBody)
          .foregroundStyle(Color.indulgeText.opacity(0.66))
          .fixedSize(horizontal: false, vertical: true)
          Button("Create a future-life card", action: presentPlayground)
            .buttonStyle(.borderedProminent)
            .tint(Color.indulgeNavy)
        } else {
          Text(
            "Your authored room remains your visual home. Optional card creation is unavailable on this device."
          )
          .font(.indulgeBody)
          .foregroundStyle(Color.indulgeText.opacity(0.62))
          .fixedSize(horizontal: false, vertical: true)
        }
      }
      .padding(18)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        Color.indulgeCherry.opacity(0.06),
        in: RoundedRectangle(cornerRadius: 20, style: .continuous)
      )
      .imagePlaygroundSheet(
        isPresented: $presentsPlayground,
        concepts: FutureLifeCardConcepts.texts(for: profile).map(ImagePlaygroundConcept.text),
        onCompletion: retainGeneratedImage,
        onCancellation: { creationState = .cancelled }
      )
      .confirmationDialog(
        "Delete this future-life card?",
        isPresented: $confirmsDeletion,
        titleVisibility: .visible
      ) {
        Button("Delete card", role: .destructive, action: deleteCard)
        Button("Keep card", role: .cancel) {}
      } message: {
        Text(
          "The generated image and its saved directions will be removed. Your authored room is unchanged."
        )
      }
      .alert("Card could not be updated", isPresented: errorBinding) {
        Button("OK", role: .cancel) {}
      } message: {
        Text(errorMessage ?? "Please try again.")
      }
      .task(id: cards.first?.imageFileName) {
        await loadRetainedImage()
      }
    }

    private func retainGeneratedImage(_ url: URL) {
      do {
        _ = try FutureLifeCardRepository(
          context: modelContext,
          assets: FutureLifeCardAssetStore()
        ).retain(imageAt: url, lifeDirections: profile.lifeDirections)
        creationState = .retained
      } catch {
        creationState = .idle
        errorMessage = "Your saved card was not changed. Please try again."
      }
    }

    private func deleteCard() {
      guard let card = cards.first else { return }
      do {
        try FutureLifeCardRepository(
          context: modelContext,
          assets: FutureLifeCardAssetStore()
        ).delete(card)
      } catch {
        errorMessage = "The card could not be removed. Please try again."
      }
    }

    private func loadRetainedImage() async {
      guard let card = cards.first else {
        if let assets = try? FutureLifeCardAssetStore() {
          try? assets.deleteUnreferencedFiles(retaining: [])
        }
        retainedImage = nil
        resolvedImageFileName = nil
        return
      }
      let fileName = card.imageFileName
      guard
        let assets = try? FutureLifeCardAssetStore(),
        let url = try? assets.url(for: fileName)
      else {
        retainedImage = nil
        resolvedImageFileName = fileName
        return
      }
      try? assets.deleteUnreferencedFiles(retaining: Set(cards.map(\.imageFileName)))

      let image = await Task.detached(priority: .utility) {
        UIImage(contentsOfFile: url.path)?.preparingForDisplay()
      }.value
      guard !Task.isCancelled, cards.first?.imageFileName == fileName else { return }
      retainedImage = image
      resolvedImageFileName = fileName
    }

    private var canCreate: Bool {
      FutureLifeCardAvailability.isActionVisible(
        supportsSystemSheet: supportsImagePlayground,
        lifeDirections: profile.lifeDirections
      )
    }

    private func presentPlayground() {
      creationState = .presenting
      presentsPlayground = true
    }

    private var errorBinding: Binding<Bool> {
      Binding(
        get: { errorMessage != nil },
        set: { if !$0 { errorMessage = nil } }
      )
    }
  }
#endif
