import SwiftUI
import RevenueCat
import RevenueCatUI

struct ContentView: View {

    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @State private var showPaywall = false
    @State private var showCustomerCenter = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {

                // MARK: - Header
                VStack(spacing: 8) {
                    Text("LangSwitch")
                        .font(.largeTitle.bold())
                    Text("Convert code between 25+ languages")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)

                // MARK: - Subscription Badge
                subscriptionBadge

                Spacer()

                // MARK: - Main Content (gated behind Pro)
                if subscriptionManager.isProUser {
                    proContent
                } else {
                    freeContent
                }

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        if subscriptionManager.isProUser {
                            Button {
                                showCustomerCenter = true
                            } label: {
                                Label("Manage Subscription", systemImage: "creditcard")
                            }
                        } else {
                            Button {
                                showPaywall = true
                            } label: {
                                Label("Upgrade to Pro", systemImage: "star.fill")
                            }
                        }

                        Button {
                            Task { await subscriptionManager.restorePurchases() }
                        } label: {
                            Label("Restore Purchases", systemImage: "arrow.clockwise")
                        }
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showPaywall) {
                RevenueCatUI.PaywallView(displayCloseButton: true)
                    .onPurchaseCompleted { customerInfo in
                        subscriptionManager.customerInfo = customerInfo
                        showPaywall = false
                    }
                    .onRestoreCompleted { customerInfo in
                        subscriptionManager.customerInfo = customerInfo
                        showPaywall = false
                    }
            }
            .presentCustomerCenter(isPresented: $showCustomerCenter) {
                showCustomerCenter = false
            }
            .task {
                await subscriptionManager.refresh()
            }
        }
    }

    // MARK: - Subscription Badge

    @ViewBuilder
    private var subscriptionBadge: some View {
        if subscriptionManager.isProUser {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.seal.fill")
                Text("Pro")
                    .fontWeight(.semibold)
            }
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.green.opacity(0.15))
            .foregroundStyle(.green)
            .clipShape(Capsule())
        } else {
            HStack(spacing: 6) {
                Image(systemName: "lock.fill")
                Text("Free")
                    .fontWeight(.semibold)
            }
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.secondary.opacity(0.15))
            .foregroundStyle(.secondary)
            .clipShape(Capsule())
        }
    }

    // MARK: - Pro Content

    private var proContent: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(.yellow)

            Text("You have full access!")
                .font(.title3.bold())

            Text("All 25+ languages • Unlimited conversions • Priority support")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            // Your app's main conversion UI goes here
        }
    }

    // MARK: - Free Content (Upsell)

    private var freeContent: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text("Unlock LangSwitch Pro")
                .font(.title3.bold())

            Text("Get unlimited conversions, all languages, and priority support.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showPaywall = true
            } label: {
                Text("View Plans")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.black)
        }
    }
}
