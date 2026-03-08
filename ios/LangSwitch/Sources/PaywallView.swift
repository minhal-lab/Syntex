import SwiftUI
import RevenueCat
import RevenueCatUI

/// Presents the RevenueCat paywall using RevenueCatUI.
/// Configure your paywall design in the RevenueCat dashboard.
struct PaywallView: View {

    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        PaywallView_RC()
    }
}

// MARK: - RevenueCat Paywall Wrapper

/// Wraps RevenueCatUI's built-in PaywallView with custom handling.
private struct PaywallView_RC: View {

    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        RevenueCatUI.PaywallView(
            displayCloseButton: true
        )
        .onPurchaseCompleted { customerInfo in
            Task { @MainActor in
                subscriptionManager.customerInfo = customerInfo
            }
            dismiss()
        }
        .onRestoreCompleted { customerInfo in
            Task { @MainActor in
                subscriptionManager.customerInfo = customerInfo
            }
            dismiss()
        }
    }
}

// MARK: - Paywall Footer (for inline use)

/// Use this when you want to show the paywall as a footer
/// attached to your own custom content.
struct PaywallFooterView: View {

    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    let content: AnyView

    init<Content: View>(@ViewBuilder content: () -> Content) {
        self.content = AnyView(content())
    }

    var body: some View {
        content
            .paywallFooter(
                purchaseCompleted: { customerInfo in
                    Task { @MainActor in
                        subscriptionManager.customerInfo = customerInfo
                    }
                },
                restoreCompleted: { customerInfo in
                    Task { @MainActor in
                        subscriptionManager.customerInfo = customerInfo
                    }
                }
            )
    }
}

// MARK: - Modifier for gating features behind paywall

extension View {
    /// Present a paywall sheet when the user doesn't have the Pro entitlement.
    func presentPaywallIfNeeded() -> some View {
        self.modifier(PaywallGateModifier())
    }
}

private struct PaywallGateModifier: ViewModifier {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @State private var showPaywall = false

    func body(content: Content) -> some View {
        content
            .onAppear {
                if !subscriptionManager.isProUser {
                    showPaywall = true
                }
            }
            .sheet(isPresented: $showPaywall) {
                RevenueCatUI.PaywallView(displayCloseButton: true)
                    .onPurchaseCompleted { customerInfo in
                        Task { @MainActor in
                            subscriptionManager.customerInfo = customerInfo
                        }
                        showPaywall = false
                    }
                    .onRestoreCompleted { customerInfo in
                        Task { @MainActor in
                            subscriptionManager.customerInfo = customerInfo
                        }
                        showPaywall = false
                    }
            }
    }
}
