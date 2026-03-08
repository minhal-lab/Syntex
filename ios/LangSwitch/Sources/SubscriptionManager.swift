import Foundation
import RevenueCat

/// Central manager for all RevenueCat subscription logic.
@MainActor
final class SubscriptionManager: ObservableObject {

    static let shared = SubscriptionManager()

    // MARK: - Published State

    @Published var customerInfo: CustomerInfo?
    @Published var offerings: Offerings?
    @Published var isLoading = false
    @Published var error: String?

    // MARK: - Entitlement & Product IDs

    static let proEntitlementID = "LangSwitch Pro"

    enum ProductID: String, CaseIterable {
        case monthly  = "monthly"
        case yearly   = "yearly"
        case lifetime = "lifetime"
    }

    // MARK: - Computed

    var isProUser: Bool {
        customerInfo?.entitlements[Self.proEntitlementID]?.isActive == true
    }

    var activeSubscription: String? {
        guard let entitlement = customerInfo?.entitlements[Self.proEntitlementID],
              entitlement.isActive else { return nil }
        return entitlement.productIdentifier
    }

    var expirationDate: Date? {
        customerInfo?.entitlements[Self.proEntitlementID]?.expirationDate
    }

    // MARK: - Init

    private init() {
        // Set delegate to listen for customer info changes
        Purchases.shared.delegate = self
        Task { await refresh() }
    }

    // MARK: - Fetch Offerings

    func fetchOfferings() async {
        isLoading = true
        error = nil
        do {
            offerings = try await Purchases.shared.offerings()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Purchase

    func purchase(_ package: Package) async -> Bool {
        isLoading = true
        error = nil
        do {
            let result = try await Purchases.shared.purchase(package: package)
            if !result.userCancelled {
                customerInfo = result.customerInfo
                isLoading = false
                return true
            }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
        return false
    }

    // MARK: - Restore Purchases

    func restorePurchases() async -> Bool {
        isLoading = true
        error = nil
        do {
            customerInfo = try await Purchases.shared.restorePurchases()
            isLoading = false
            return isProUser
        } catch {
            self.error = error.localizedDescription
            isLoading = false
            return false
        }
    }

    // MARK: - Refresh

    func refresh() async {
        do {
            customerInfo = try await Purchases.shared.customerInfo()
        } catch {
            self.error = error.localizedDescription
        }
        await fetchOfferings()
    }
}

// MARK: - PurchasesDelegate

extension SubscriptionManager: PurchasesDelegate {
    nonisolated func purchases(
        _ purchases: Purchases,
        receivedUpdated customerInfo: CustomerInfo
    ) {
        Task { @MainActor in
            self.customerInfo = customerInfo
        }
    }
}
