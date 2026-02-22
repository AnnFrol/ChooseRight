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
        // Проверяем все завершенные транзакции для единовременной покупки
        var purchased = false
        
        // Проверяем текущие entitlements (для подписок и consumables)
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.productID == premiumProductID {
                    purchased = true
                    break
                }
            } catch {
                #if DEBUG
                print("Failed to verify transaction: \(error)")
                #endif
            }
        }
        
        // Для единовременных покупок также проверяем все завершенные транзакции
        if !purchased {
            for await result in Transaction.all {
                do {
                    let transaction = try checkVerified(result)
                    if transaction.productID == premiumProductID {
                        purchased = true
                        break
                    }
                } catch {
                    #if DEBUG
                    print("Failed to verify transaction: \(error)")
                    #endif
                }
            }
        }
        
        hasPurchasedPremium = purchased
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
