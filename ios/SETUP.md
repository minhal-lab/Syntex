# LangSwitch iOS — RevenueCat Integration Setup

## 1. Create Xcode Project

1. Open Xcode → **File → New → Project → App**
2. Product Name: `LangSwitch`
3. Interface: **SwiftUI**, Language: **Swift**
4. Save it inside `ios/LangSwitch/`

## 2. Add RevenueCat SDK (Swift Package Manager)

1. In Xcode: **File → Add Package Dependencies...**
2. Enter this URL in the search bar:
   ```
   https://github.com/RevenueCat/purchases-ios-spm.git
   ```
3. Set version rule to **Up to Next Major Version**
4. Add **both** packages to your target:
   - `RevenueCat`
   - `RevenueCatUI`

## 3. Enable In-App Purchase Capability

1. Select your project in the navigator
2. Select your target → **Signing & Capabilities**
3. Click **+ Capability** → search for **In-App Purchase** → add it

## 4. Add the Swift Files

Copy these files into your Xcode project (drag into the Sources group):
- `LangSwitchApp.swift` (replace the auto-generated App file)
- `SubscriptionManager.swift`
- `PaywallView.swift`
- `CustomerCenterView.swift`
- `ContentView.swift` (replace the auto-generated one)

## 5. RevenueCat Dashboard Setup

In [app.revenuecat.com](https://app.revenuecat.com):

### Products
Create these products (must match App Store Connect):
| Identifier | Type |
|---|---|
| `monthly` | Auto-Renewable Subscription |
| `yearly` | Auto-Renewable Subscription |
| `lifetime` | Non-Consumable |

### Entitlements
Create one entitlement:
- Identifier: `LangSwitch Pro`
- Attach all 3 products to it

### Offerings
Create a default offering with packages:
- `$rc_monthly` → `monthly`
- `$rc_annual` → `yearly`
- `$rc_lifetime` → `lifetime`

### Paywalls
Design your paywall in **RevenueCat Dashboard → Paywalls** — RevenueCatUI renders it automatically.

### Customer Center
Configure in **RevenueCat Dashboard → Customer Center** — set up paths for cancellation, refunds, etc.

## 6. App Store Connect

1. Create your subscription group and products in App Store Connect
2. Match the product identifiers exactly: `monthly`, `yearly`, `lifetime`
3. Set up pricing for each product

## 7. Before Release

- Change `Purchases.logLevel` from `.debug` to `.warn` in `LangSwitchApp.swift`
- Replace `test_zxyxYMOKeVMHATXOwrHCzepLsBZ` with your **production** API key

## Architecture Overview

```
LangSwitchApp.swift       → Configures RevenueCat on launch
SubscriptionManager.swift → Singleton managing all purchase state
PaywallView.swift          → RevenueCatUI paywall + helpers
CustomerCenterView.swift   → Subscription management UI
ContentView.swift          → Main app with Pro/Free gating
```
