import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let monthlyProductID = "within.monthly"

    @Published private(set) var product: Product?
    @Published private(set) var isEntitled = false
    @Published private(set) var isLoading = false
    @Published var message: String?

    func prepare() async {
        isLoading = true
        defer { isLoading = false }
        do {
            product = try await Product.products(for: [Self.monthlyProductID]).first
            await refreshEntitlement()
            if product == nil {
                message = "The App Store subscription is not configured yet. Add within.monthly in App Store Connect."
            }
        } catch {
            message = "The App Store could not load membership right now."
        }
    }

    func purchase() async {
        guard let product else {
            message = "Membership is not available in this build yet."
            return
        }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try verified(verification)
                await transaction.finish()
                await refreshEntitlement()
            case .pending:
                message = "The purchase is waiting for approval."
            case .userCancelled:
                break
            @unknown default:
                message = "The purchase could not be completed."
            }
        } catch {
            message = "The purchase could not be verified."
        }
    }

    func restore() async {
        do {
            try await AppStore.sync()
            await refreshEntitlement()
            message = isEntitled ? "Membership restored." : "No active membership was found."
        } catch {
            message = "Restore could not be completed."
        }
    }

    private func refreshEntitlement() async {
        isEntitled = false
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? verified(result) else { continue }
            if transaction.productID == Self.monthlyProductID, transaction.revocationDate == nil {
                isEntitled = true
                return
            }
        }
    }

    private func verified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value): value
        case .unverified: throw StoreError.failedVerification
        }
    }

    private enum StoreError: Error { case failedVerification }
}
