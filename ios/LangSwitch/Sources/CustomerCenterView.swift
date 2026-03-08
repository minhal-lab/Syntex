import SwiftUI
import RevenueCat
import RevenueCatUI

/// Presents RevenueCat's Customer Center for managing subscriptions.
/// Users can view, modify, or cancel their subscriptions here.
struct CustomerCenterView: View {

    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            CustomerCenterContent()
                .navigationTitle("Manage Subscription")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
        }
    }
}

private struct CustomerCenterContent: View {

    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    var body: some View {
        if #available(iOS 15.0, *) {
            CustomerCenterView_RC()
        } else {
            CustomerCenterFallback()
        }
    }
}

// MARK: - RevenueCat Customer Center (iOS 16+)

@available(iOS 15.0, *)
private struct CustomerCenterView_RC: View {

    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    var body: some View {
        RevenueCatUI.CustomerCenterView()
            .onCustomerCenterRestoreCompleted { customerInfo in
                Task { @MainActor in
                    subscriptionManager.customerInfo = customerInfo
                }
            }
            .onCustomerCenterRestoreFailed { error in
                Task { @MainActor in
                    subscriptionManager.error = error.localizedDescription
                }
            }
            .onCustomerCenterShowingManageSubscriptions {
                // User tapped manage — system handles the redirect
            }
            .onCustomerCenterRefundRequestStarted { productID in
                // Track refund request if needed
            }
    }
}

// MARK: - Fallback for older iOS

private struct CustomerCenterFallback: View {

    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    var body: some View {
        List {
            Section("Subscription Status") {
                if subscriptionManager.isProUser {
                    Label("LangSwitch Pro Active", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(.green)

                    if let product = subscriptionManager.activeSubscription {
                        LabeledContent("Plan", value: product)
                    }

                    if let expiry = subscriptionManager.expirationDate {
                        LabeledContent("Renews") {
                            Text(expiry, style: .date)
                        }
                    }
                } else {
                    Label("Free Plan", systemImage: "xmark.circle")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button("Restore Purchases") {
                    Task {
                        await subscriptionManager.restorePurchases()
                    }
                }

                if subscriptionManager.isProUser {
                    Link("Manage in Settings",
                         destination: URL(string: "https://apps.apple.com/account/subscriptions")!)
                }
            }

            if let error = subscriptionManager.error {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
        }
    }
}
