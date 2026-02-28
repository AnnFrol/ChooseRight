//
//  SubscriptionManager.swift
//  ChooseRight!
//
//  Manages one-time in-app purchases using StoreKit
//

import Foundation
import StoreKit

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    // Product ID для единовременной покупки - нужно настроить в App Store Connect
    // Цена: $9.99 (единовременная покупка навсегда)
    private let premiumProductID = "com.chooseright.premium"
    
    @Published var products: [Product] = []
    @Published var hasPurchasedPremium = false
    @Published var isLoading = false
    
    private var updateListenerTask: Task<Void, Error>?
    
    private init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()
        
        Task {
            await requestProducts()
            await updatePurchasedStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    
    func requestProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            products = try await Product.products(for: [premiumProductID])
        } catch {
            #if DEBUG
            print("Failed to load products: \(error)")
            #endif
        }
    }
    
    // MARK: - Purchase
    
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updatePurchasedStatus()
            return transaction
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }
    
    // MARK: - Purchase Status
    
    var hasActiveSubscription: Bool {
        hasPurchasedPremium
    }
    
    func updatePurchasedStatus() async {
        // Проверяем текущие entitlements. 
        // Это самый надежный способ для StoreKit 2: он содержит только АКТИВНЫЕ покупки.
        // Если был возврат (Refund), покупка исчезнет из этого списка автоматически.
        var purchased = false
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.productID == premiumProductID {
                    // Для Non-Consumable достаточно найти одну активную транзакцию
                    purchased = true
                    break
                }
            } catch {
                #if DEBUG
                print("Failed to verify transaction: \(error)")
                #endif
            }
        }
        
        // Transaction.all проверять не нужно для Non-Consumable, так как он содержит и отозванные (refunded) покупки.
        // Доверяем currentEntitlements.
        
        hasPurchasedPremium = purchased
        
        // Уведомляем другие части приложения об изменении статуса
        NotificationCenter.default.post(name: .premiumStatusChanged, object: nil)
    }
    
    // MARK: - Restore
    
    func restorePurchases() async throws {
        // Принудительная синхронизация с App Store.
        // Это заставляет устройство загрузить отсутствующие транзакции (например, на новом устройстве).
        // Требует ввода пароля Apple ID (в Sandbox тоже может попросить).
        try await AppStore.sync()
        await updatePurchasedStatus()
    }
    
    // MARK: - Helper Methods
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task { @MainActor in
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await transaction.finish()
                    await self.updatePurchasedStatus()
                } catch {
                    #if DEBUG
                    print("Transaction verification failed: \(error)")
                    #endif
                }
            }
        }
    }
    
    // MARK: - Free Tier Check
    
    func canCreateComparison(freeComparisonsCount: Int) -> Bool {
        if hasPurchasedPremium {
            return true
        }
        return freeComparisonsCount < 1
    }
}

enum StoreError: Error {
    case failedVerification
}

extension Notification.Name {
    static let premiumStatusChanged = Notification.Name("premiumStatusChanged")
}
