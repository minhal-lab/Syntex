import SwiftUI
import RevenueCat

@main
struct LangSwitchApp: App {

    init() {
        // Configure RevenueCat — do this as early as possible
        Purchases.logLevel = .debug  // Remove in production
        Purchases.configure(
            with: .builder(withAPIKey: "test_zxyxYMOKeVMHATXOwrHCzepLsBZ")
                .with(appUserID: nil)  // Anonymous — RevenueCat generates an ID
                .build()
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(SubscriptionManager.shared)
        }
    }
}
