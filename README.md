# Trello Watch Companion App
https://drive.google.com/file/d/10uoUdQL4VoOJZLzmdQ2p1cIF8utW1cCb/view?usp=sharing, https://aistudio.google.com/app/prompts?state=%7B%22ids%22:%5B%221YA8XFPE_qSdMBWZAbV4CeEWry_QXjtZT%22%5D,%22action%22:%22open%22,%22userId%22:%22101478228369990562741%22,%22resourceKeys%22:%7B%7D%7D&usp=sharing
## Overview

This project demonstrates a basic implementation of a Trello client for watchOS (version 11 target assumed) paired with a companion iOS application. It allows users to authenticate with their Trello account via the iOS app, view their Trello boards and cards on their Apple Watch, and move cards between lists directly from the watch.

The implementation is based on the provided Trello REST API OpenAPI specification (`trelloopenapi.json`).

**Note:** This is a conceptual implementation focusing on core functionality and structure. It lacks robust error handling, advanced UI features, and comprehensive security measures beyond basic Keychain usage on iOS.

## Features

### iOS Companion App

*   Provides input fields for Trello API Key and API Token.
*   Securely stores the API Key and Token in the iOS Keychain.
*   Sends the credentials to the paired Apple Watch using WatchConnectivity.
*   Displays the status of the WatchConnectivity session (app installed, reachable).
*   Allows clearing stored credentials from the Keychain.

### watchOS App

*   Receives Trello credentials securely from the companion iOS app via WatchConnectivity.
*   Displays an authentication required message until credentials are received.
*   Fetches and displays a list of the user's open Trello boards.
*   Allows navigation into a selected board.
*   Displays the board's lists (columns) using a horizontal `TabView`.
*   Displays the cards within each list vertically.
*   Allows tapping on a card to initiate a move action.
*   Presents a modal sheet to select the destination list for the card.
*   Performs the card move via the Trello API.
*   Uses optimistic UI updates for smoother card moving experience (updates local state immediately, reverts on API failure).

## Prerequisites

*   **Xcode:** Version 15 or later recommended (for Swift 5.9+, watchOS 10/11 SDKs).
*   **Apple Developer Account:** Required for enabling App Groups and running on physical devices.
*   **Physical iPhone and Apple Watch:** Required for proper testing of WatchConnectivity features. Simulators have limitations.
*   **Trello Account:** You need a Trello account to interact with the API.
*   **Trello API Key and Token:**
    *   Generate these from the [Trello Developer Portal](https://trello.com/app-key).
    *   **API Key:** Identifies your application.
    *   **API Token:** Grants access on behalf of your Trello user account. Keep this secure!

## Configuration Steps

1.  **Download/Clone:** Obtain the project source code.
2.  **Open in Xcode:** Open the `.xcodeproj` file.
3.  **Bundle Identifiers:** Set unique Bundle Identifiers for both the iOS (`TrelloCompanionApp`) and watchOS (`TrelloWatchApp`) targets in the "Signing & Capabilities" tab. (e.g., `com.yourcompany.TrelloCompanionApp`, `com.yourcompany.TrelloCompanionApp.watchkitapp`).
4.  **Development Team:** Select your Apple Developer account team for both targets under "Signing & Capabilities".
5.  **App Group:**
    *   This is **highly recommended** if you plan to share data beyond basic WatchConnectivity messages (like using a shared Keychain group, which is more secure for watchOS credential storage than the current UserDefaults implementation).
    *   Go to "Signing & Capabilities" for **both** the iOS target and the watchOS App target (e.g., `TrelloWatchApp`).
    *   Click "+ Capability" and add "App Groups".
    *   Click the "+" button under App Groups and create a new group identifier (e.g., `group.com.yourcompany.TrelloCompanionApp`). **Use the same identifier for both targets.**
    *   Ensure the checkbox next to the created group is checked for both targets.
6.  **Keychain Service Name (iOS App):**
    *   Open `TrelloCompanionApp/KeychainHelper.swift`.
    *   Locate the constant `keychainServiceName`.
    *   **IMPORTANT:** Change the value `"com.votredomaine.votreapp.trello"` to a unique string, typically based on your iOS app's bundle identifier (e.g., `"com.yourcompany.TrelloCompanionApp.trello"`). This ensures your app's keychain items don't conflict with others.

## Build Instructions

1.  **Connect Devices:** Connect your physical iPhone to your Mac. Ensure your Apple Watch is paired with the iPhone and unlocked.
2.  **Select iOS Scheme:** In Xcode, select the scheme for the iOS companion app (e.g., `TrelloCompanionApp`).
3.  **Select iPhone Device:** Choose your connected iPhone as the run destination.
4.  **Build & Run (iOS):** Press `Cmd + R` or click the Run button. Install the app on your iPhone.
5.  **Select watchOS Scheme:** In Xcode, select the scheme for the watchOS app (e.g., `TrelloWatchApp`).
6.  **Select Watch Device:** Choose your paired Apple Watch as the run destination (it should appear under your iPhone).
7.  **Build & Run (watchOS):** Press `Cmd + R` or click the Run button. Xcode will build the watch app and install it via the paired iPhone.

## Usage Guide

1.  **Launch iOS App:** Open the Trello Companion app on your iPhone.
2.  **Enter Credentials:** Paste your generated Trello API Key and API Token into the respective fields.
3.  **Save & Send:** Tap the "Sauvegarder et Envoyer à la Montre" button.
    *   Observe the status messages. It should indicate saving to Keychain and attempting to send.
    *   The WatchConnectivity status indicator should ideally show the watch as reachable (green watch face icon).
    *   A success message should appear if the credentials were sent successfully.
4.  **Launch watchOS App:** Open the Trello app on your Apple Watch.
    *   Initially, it might show the "Authentification requise" message.
    *   Once it receives the credentials from the iPhone (this might take a few seconds, especially the first time), it should automatically transition to a loading state ("Chargement...").
    *   The list of your open Trello boards should appear.
5.  **Navigate (Watch):**
    *   Tap a board name to view its details.
    *   Swipe horizontally to switch between lists (columns).
    *   Scroll vertically to see cards within a list.
6.  **Move Card (Watch):**
    *   Tap on the name of a card you want to move.
    *   A modal sheet will appear titled "Vers...".
    *   Tap the name of the destination list.
    *   The sheet will dismiss, and the card should visually move to the new list in the UI (optimistic update). The API call happens in the background.

## Debugging Tips

*   **Console Logs:** Check the Xcode console output for BOTH the iOS and watchOS processes. Use `print` statements liberally in ViewModels, Session Managers, and API Services to track execution flow and variable values.
*   **WatchConnectivity:**
    *   **Activation:** Check logs in `PhoneSessionManager` and `WatchSessionManager` for successful activation (`activationDidCompleteWith`).
    *   **State:** Monitor `isWatchAppInstalled` and `isReachable` in the iOS app UI and logs. The watch must be unlocked and nearby for `isReachable` to be true. Bluetooth/Wi-Fi must be enabled.
    *   **Messaging:** Look for `sendMessage` logs on the phone and `didReceiveMessage` logs on the watch. Check for any errors passed to the `errorHandler` or `replyHandler`. Ensure the dictionary keys (`apiKey`, `apiToken`) match exactly.
    *   **First Connection:** Sometimes the first message send/receive after installation can be delayed. Try sending again if it doesn't work immediately. Ensure both apps have been run at least once.
*   **Authentication (Watch):**
    *   Verify credentials reception in `WatchSessionManager` logs.
    *   Check if `WatchSessionManager.shared.credentials` is non-nil in the watch `ContentView`.
    *   Ensure the `apiService.setCredentials` method is called correctly in `BoardListViewModel` when credentials change or the view appears.
    *   Look for `401 Unauthorized` errors (or `TrelloError.invalidCredentials`) in `TrelloAPIService` logs on the watch. Double-check the Key/Token entered on the iPhone.
*   **API Calls (Watch):**
    *   Examine `TrelloAPIService` logs for the constructed URL, HTTP status codes, and any specific error messages (`TrelloError.apiError`, `TrelloError.networkError`, `TrelloError.decodingError`).
    *   Common issues: Incorrect `boardId`/`cardId`/`listId`, network connectivity problems on the watch/iPhone, Trello API rate limits, or changes in the Trello API response format causing decoding errors.
*   **Keychain (iOS):**
    *   Check `KeychainHelper` logs for save/load/delete success or failure messages.
    *   Pay attention to `OSStatus` codes if errors occur (you can look these up online).
    *   Ensure the `keychainServiceName` is unique and correctly configured.
    *   On the Simulator, you can use "Device" -> "Erase All Content and Settings..." to reset the keychain if needed. On a device, deleting the app *should* remove its keychain items.
*   **App Group (If Sharing Data):** Double-check that the App Group identifier in "Signing & Capabilities" is **identical** for both the iOS and watchOS targets.
*   **SwiftUI:**
    *   Ensure `@StateObject` is used for ViewModels owned/created by a View, and `@ObservedObject` for ViewModels passed into a View.
    *   Verify that changes to `@Published` properties in ViewModels are happening on the main thread (use `@MainActor` on classes or specific functions).
    *   Use `print` statements inside view `body` properties (sparingly) or `.onChange` modifiers to track view updates.

## Known Limitations & Future Improvements

*   **watchOS Credential Storage:** Currently uses `UserDefaults` for simplicity, which is **not secure**. Should ideally use Keychain with App Group sharing or fetch credentials from iPhone on demand.
*   **Error Handling:** Basic error messages are shown. More user-friendly alerts, specific retry logic, and better state management during errors could be added.
*   **UI/UX:** The interface is functional but basic. Could be improved with better loading states, visual feedback on actions, custom styling, and potentially complications.
*   **Performance:** Loading all lists and cards for a board at once might be slow for large boards. Lazy loading or pagination could be implemented. The optimistic UI update helps perceived performance.
*   **Offline Support:** No offline caching or functionality. Requires active connection via the paired iPhone.
*   **Limited Functionality:** Only supports viewing open boards/lists/cards and moving cards. No creation, editing, deletion, searching, viewing closed items, attachments, comments, due dates, etc.
*   **Background Refresh:** The watch app doesn't currently fetch data in the background.

## Technology Stack

*   **SwiftUI:** For building the user interface for both iOS and watchOS.
*   **WatchConnectivity:** For communication between the iPhone and Apple Watch.
*   **Combine / async/await:** For handling asynchronous operations (API calls, WatchConnectivity).
*   **URLSession:** For making network requests to the Trello API.
*   **Security Framework (Keychain Services):** For secure storage of credentials on iOS.

## License

(Optional) Specify a license, e.g.:
MIT License
