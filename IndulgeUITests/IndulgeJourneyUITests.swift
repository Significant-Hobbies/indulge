import XCTest

@MainActor
final class IndulgeJourneyUITests: XCTestCase {
  private var app: XCUIApplication!

  nonisolated override func setUpWithError() throws {
    continueAfterFailure = false
  }

  func testCoreOnboardingUsesTheKeyboardRetainsAnswersAndRestoresTheApp() {
    launchApp(["--onboarding", "--personal-keyboard", "--reset-testing-data"])
    XCTAssertFalse(app.buttons["Skip"].exists)

    let nameField = app.textFields["Your name"]
    XCTAssertTrue(nameField.waitForExistence(timeout: 4))
    nameField.tap()
    nameField.typeText("Maya")
    submitTextEntry()

    tapButton("Woman")
    tapButton("Continue")

    tapButton("Back")
    XCTAssertTrue(app.staticTexts["How do you describe your gender?"].waitForExistence(timeout: 3))
    tapButton("Back")
    XCTAssertTrue(app.textFields["Your name"].waitForExistence(timeout: 3))
    XCTAssertEqual(app.textFields["Your name"].value as? String, "Maya")
    tapButton("Continue")

    tapButton("Continue")

    tapButton("Watching TV")
    tapButton("Continue")

    tapButton("Watching TV")
    tapButton("That’s the one")

    tapButton("Around 2 hours")
    tapButton("That sounds right")

    tapButton("Something comforting")
    tapButton("Continue")

    tapButton("More presence")
    tapButton("I want more of this")

    XCTAssertTrue(app.staticTexts["Maya, here’s your pattern."].waitForExistence(timeout: 4))
    XCTAssertFalse(app.buttons["Skip"].exists)
    tapButton("Start with this")

    XCTAssertTrue(app.staticTexts["Your life, taking shape."].waitForExistence(timeout: 5))
    assertTabExists("Life")
    assertTabExists("Trade")
    assertTabExists("History")

    app.terminate()
    app.launchArguments = []
    app.launch()

    XCTAssertTrue(app.staticTexts["Your life, taking shape."].waitForExistence(timeout: 5))
  }

  func testLifeSceneOpensTradeAndTheNativeSettingsRemainReachable() {
    resetTestingData()
    launchApp(["--app-life"])

    XCTAssertTrue(app.staticTexts["Your life, taking shape."].waitForExistence(timeout: 5))
    tapButton("Shape this indulgence")
    XCTAssertTrue(
      app.staticTexts["Trade a little drift for something you want."].waitForExistence(timeout: 4))

    tapButton("More creativity")
    tapButton("15 min")
    tapButton("Create this trade")
    XCTAssertTrue(app.staticTexts["Your time has somewhere to go."].waitForExistence(timeout: 4))

    tapTab("Life")
    XCTAssertTrue(app.staticTexts["Your first trade is ready"].waitForExistence(timeout: 4))

    tapTab("History")
    let emptyHistory = app.staticTexts["Waiting for your first completed trade"]
    let populatedHistory = app.staticTexts["The choices you actually made."]
    XCTAssertTrue(
      emptyHistory.waitForExistence(timeout: 2) || populatedHistory.waitForExistence(timeout: 2)
    )

    tapTab("Life")
    tapButton("Privacy and data settings")
    XCTAssertTrue(
      app.staticTexts["Keep the pleasure. Reclaim the time."].waitForExistence(timeout: 4))
    assertReachable(app.buttons["Delete all Indulge data"])
    assertReachable(app.switches["Require device authentication"])
    tapButton("Done")
  }

  func testTradeCompletionPersistsIntoHistoryAndAllDataDeletionReturnsToFirstRun() {
    resetTestingData()
    launchApp(["--app-trade-active"])

    XCTAssertTrue(app.staticTexts["Your time has somewhere to go."].waitForExistence(timeout: 5))

    tapButton("Choose a different trade")
    tapButton("More creativity")
    tapButton("30 min")
    tapButton("Replace active trade")

    tapButton("Begin this trade")
    XCTAssertTrue(app.buttons["Finish this trade"].waitForExistence(timeout: 4))
    tapButton("Finish this trade")
    tapButton("I made some room")

    XCTAssertTrue(app.staticTexts["Made room"].waitForExistence(timeout: 4))
    tapButton("Done")
    tapTab("History")
    XCTAssertTrue(app.staticTexts["The choices you actually made."].waitForExistence(timeout: 4))
    XCTAssertTrue(
      app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'minutes you said became room'"))
        .firstMatch.exists)

    app.terminate()
    app.launchArguments = ["--app-history"]
    app.launch()
    XCTAssertTrue(app.staticTexts["The choices you actually made."].waitForExistence(timeout: 5))
    XCTAssertTrue(app.staticTexts["Made room"].exists)

    tapTab("Life")
    tapButton("Privacy and data settings")
    tapButton("Delete all Indulge data")
    tapButton("Delete all data")
    XCTAssertTrue(app.staticTexts["What should we call you?"].waitForExistence(timeout: 5))
  }

  func testPhysicalPersistenceAndSupportedAppleCapabilityState() throws {
    #if targetEnvironment(simulator)
      throw XCTSkip("This acceptance check is intentionally reserved for paired physical hardware.")
    #else
      launchApp([])

      XCTAssertTrue(app.staticTexts["Your life, taking shape."].waitForExistence(timeout: 8))
      assertTabExists("Life")
      assertTabExists("Trade")
      assertTabExists("History")

      let createCard = app.buttons["Create a future-life card"]
      let unavailableCard = app.staticTexts[
        "Your authored room remains your visual home. Optional card creation is unavailable on this device."
      ]
      for _ in 0..<12 where !createCard.exists && !unavailableCard.exists {
        app.swipeUp()
      }
      XCTAssertTrue(
        createCard.exists || unavailableCard.exists,
        "Expected the physical device to expose either Image Playground or its deterministic fallback."
      )
      let capabilityState =
        createCard.exists ? "Image Playground available" : "Image Playground unavailable"
      XCTContext.runActivity(named: capabilityState) { activity in
        activity.add(XCTAttachment(screenshot: app.screenshot()))
      }

      tapButton("Privacy and data settings")
      let privacySwitch = app.switches["Require device authentication"]
      assertReachable(privacySwitch)
      XCTAssertTrue(privacySwitch.isEnabled)
      XCTAssertTrue(
        app.staticTexts[
          "Uses Face ID, Touch ID, or your device passcode. Indulge stores no biometric data."
        ].exists,
        "Expected LocalAuthentication to be available on physical hardware."
      )
    #endif
  }

  func testPhysicalPrivacyLockAuthenticatesAndCanBeReturnedToOff() throws {
    #if targetEnvironment(simulator)
      throw XCTSkip("This acceptance check requires physical device-owner authentication.")
    #elseif INDULGE_PHYSICAL_UI_AUTH_TEST
      launchApp([])
      XCTAssertTrue(app.staticTexts["Your life, taking shape."].waitForExistence(timeout: 8))
      tapButton("Privacy and data settings")

      let privacySwitch = app.switches["Require device authentication"]
      assertReachable(privacySwitch)
      if switchIsOn(privacySwitch) {
        privacySwitch.tap()
        XCTAssertTrue(waitForSwitch(privacySwitch, toBeOn: false, timeout: 4))
      }

      privacySwitch.tap()
      XCTAssertTrue(
        waitForSwitch(privacySwitch, toBeOn: true, timeout: 30),
        "Authenticate on the paired iPhone when the system prompt appears."
      )

      privacySwitch.tap()
      XCTAssertTrue(waitForSwitch(privacySwitch, toBeOn: false, timeout: 4))
    #else
      throw XCTSkip("Pass -DINDULGE_PHYSICAL_UI_AUTH_TEST for an explicitly attended run.")
    #endif
  }

  private func launchApp(_ arguments: [String]) {
    app = XCUIApplication()
    app.launchArguments = arguments
    app.launch()
  }

  private func resetTestingData() {
    let resetApp = XCUIApplication()
    resetApp.launchArguments = ["--onboarding", "--reset-testing-data"]
    resetApp.launch()
    resetApp.terminate()
  }

  private func submitTextEntry() {
    let continueKey = app.keyboards.buttons["continue"]
    if continueKey.waitForExistence(timeout: 2) {
      continueKey.tap()
    } else {
      nameFieldFallback().typeText("\n")
    }
  }

  private func nameFieldFallback() -> XCUIElement {
    app.textFields["Your name"]
  }

  private func tapButton(_ label: String, file: StaticString = #filePath, line: UInt = #line) {
    let button = app.buttons[label]
    if !button.waitForExistence(timeout: 2) || !button.isHittable {
      for _ in 0..<8 where !button.isHittable {
        app.swipeUp()
      }
    }
    XCTAssertTrue(button.exists, "Expected button ‘\(label)’", file: file, line: line)
    XCTAssertTrue(
      button.isHittable, "Expected button ‘\(label)’ to be hittable", file: file, line: line)
    button.tap()
  }

  private func assertReachable(
    _ element: XCUIElement, file: StaticString = #filePath, line: UInt = #line
  ) {
    if !element.exists {
      for _ in 0..<8 where !element.exists {
        app.swipeUp()
      }
    }
    XCTAssertTrue(element.exists, "Expected element to be reachable", file: file, line: line)
  }

  private func switchIsOn(_ element: XCUIElement) -> Bool {
    let value = String(describing: element.value ?? "")
    return value == "1" || value.localizedCaseInsensitiveCompare("on") == .orderedSame
  }

  private func waitForSwitch(_ element: XCUIElement, toBeOn: Bool, timeout: TimeInterval) -> Bool {
    let predicate = NSPredicate { object, _ in
      guard let element = object as? XCUIElement else { return false }
      return self.switchIsOn(element) == toBeOn
    }
    return XCTWaiter().wait(
      for: [XCTNSPredicateExpectation(predicate: predicate, object: element)],
      timeout: timeout
    ) == .completed
  }

  private func assertTabExists(
    _ label: String, file: StaticString = #filePath, line: UInt = #line
  ) {
    XCTAssertTrue(
      app.tabBars.buttons[label].exists || app.buttons[label].exists,
      "Expected tab ‘\(label)’ on the current device idiom",
      file: file,
      line: line
    )
  }

  private func tapTab(
    _ label: String, file: StaticString = #filePath, line: UInt = #line
  ) {
    let predicate = NSPredicate(format: "label == %@", label)
    let button = app.buttons.matching(predicate).firstMatch
    if button.waitForExistence(timeout: 2) {
      let ready = XCTNSPredicateExpectation(
        predicate: NSPredicate(format: "exists == true AND hittable == true"),
        object: button
      )
      if XCTWaiter().wait(for: [ready], timeout: 3) == .completed {
        button.tap()
        return
      }
    }

    let text = app.staticTexts[label]
    XCTAssertTrue(
      text.exists && text.isHittable, "Expected tab ‘\(label)’ to be hittable", file: file,
      line: line)
    if text.exists && text.isHittable { text.tap() }
  }
}
