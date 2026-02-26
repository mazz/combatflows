//
//  StoreManager.swift
//  combatflows
//
//  Created by Michael on 2026-02-25.
//  Copyright © 2026 ilearningsolutions. All rights reserved.
//


import Foundation
import StoreKit
import Combine

class StoreManager: NSObject, ObservableObject {
    @Published var fetchedProducts: [SKProduct] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isRestoring: Bool = false
    @Published var downloadProgress: [String: Double] = [:] // productID: progress (0.0 to 1.0)
    @Published var favoriteProductIDs: Set<String> = []
    
    let bundleID = "ca.ilearningsolutions.combatflows.combatflowbundle"
    private var productsRequest: SKProductsRequest?
    
    // Injecting the curriculum store so we can map product IDs to asset names
    var curriculumStore: CurriculumStore?
    
    override init() {
        super.init()
        // Register as an observer (Equivalent to IAPHelper.m line 68)
        SKPaymentQueue.default().add(self)
        
        // Load initial purchase state from local storage or file system
//        loadPurchasedStates()
        loadFavorites()
    }
    
    /// This should be called once the CurriculumStore is loaded
    func initializePurchases(with store: CurriculumStore) {
        self.curriculumStore = store
        loadPurchasedStates()
    }
    
    private func loadPurchasedStates() {
        guard let store = curriculumStore else { return }
        
        var newlyPurchasedIDs = Set<String>()
        
        // 1. Check file system for each flow group (Legacy Logic)
        for group in store.flowGroups {
            if hasPurchasedFiles(for: group.productIdentifier) {
                newlyPurchasedIDs.insert(group.productIdentifier)
            }
        }
        
        // 2. Check for the "Everything" Bundle (Legacy Logic)
        if hasPurchasedFiles(for: bundleID) {
            newlyPurchasedIDs.insert(bundleID)
        }
        
        // 3. Sync with UserDefaults for good measure
        for group in store.flowGroups {
            if UserDefaults.standard.bool(forKey: group.productIdentifier) {
                newlyPurchasedIDs.insert(group.productIdentifier)
            }
        }
        
        DispatchQueue.main.async {
            self.purchasedProductIDs = newlyPurchasedIDs
        }
    }
    
    func toggleFavorite(for productID: String) {
        if favoriteProductIDs.contains(productID) {
            favoriteProductIDs.remove(productID)
            UserDefaults.standard.set(Array(favoriteProductIDs), forKey: "favorite_flows")
        } else {
            favoriteProductIDs.insert(productID)
            UserDefaults.standard.set(Array(favoriteProductIDs), forKey: "favorite_flows")
        }
    }

    func loadFavorites() {
        let saved = UserDefaults.standard.stringArray(forKey: "favorite_flows") ?? []
        self.favoriteProductIDs = Set(saved)
    }
    
    // MARK: - Legacy File Verification Logic
    
    private var purchasedContentPath: URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentsDirectory = paths.first else { return nil }
        
        // Hardcode "combatflows" to match the legacy directory exactly
        let legacyAppName = "combatflows"
        
        return documentsDirectory
            .appendingPathComponent("CombatMMA")
            .appendingPathComponent(legacyAppName)
            .appendingPathComponent("purchased_content")
    }
    
    private func hasPurchasedFiles(for productID: String) -> Bool {
        guard let contentPath = purchasedContentPath,
              let store = curriculumStore else { return false }
        
        // Get list of files actually on disk
        let fileManager = FileManager.default
        guard let purchasedFiles = try? fileManager.contentsOfDirectory(atPath: contentPath.path) else {
            return false
        }
        let purchasedSet = Set(purchasedFiles)
        
        // Get list of assets that SHOULD be there for this productID
        // Mirroring assetNamesForProductIdentifier: from SCRProductService.m
        let requiredAssets = getRequiredAssets(for: productID, from: store)
        if requiredAssets.isEmpty { return false }
        
        // Check if all required assets are present
        let requiredSet = Set(requiredAssets)
        return requiredSet.isSubset(of: purchasedSet)
    }
    
    private func getRequiredAssets(for productID: String, from store: CurriculumStore) -> [String] {
        // Find the group matching this productID
        guard let group = store.flowGroups.first(where: { $0.productIdentifier == productID }) else {
            // If it's the bundle, we might need different logic,
            // but your legacy code used assetNamesForProductIdentifier for the bundle too.
            return []
        }
        
        // Collect all lesson filenames in this group
        var assets: [String] = []
        for flow in group.combatFlows {
            for lesson in flow.lessons {
                assets.append(lesson.filename)
            }
        }
        return assets
    }

    func fetchProducts(productIdentifiers: Set<String>) {
        productsRequest?.cancel()
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }

    func buy(product: SKProduct) {
        guard SKPaymentQueue.canMakePayments() else { return }
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func restorePurchases() {
        isRestoring = true
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}


extension StoreManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                handlePurchased(transaction)
            case .restored:
                handleRestored(transaction)
            case .failed:
                handleFailed(transaction)
            case .purchasing:
                break
            default:
                break
            }
        }
    }
    
    private func handlePurchased(_ transaction: SKPaymentTransaction) {
        let productID = transaction.payment.productIdentifier
        
        // Mark as purchased in UserDefaults (Mirroring IAPHelper.m:248)
        UserDefaults.standard.set(true, forKey: productID)
        
        if !transaction.downloads.isEmpty {
            print("📦 Starting downloads for \(productID)...")
            SKPaymentQueue.default().start(transaction.downloads)
        } else {
            purchasedProductIDs.insert(productID)
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
    private func handleFailed(_ transaction: SKPaymentTransaction) {
        if let error = transaction.error as? SKError, error.code != .paymentCancelled {
            print("Transaction failed: \(error.localizedDescription)")
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func handleRestored(_ transaction: SKPaymentTransaction) {
        purchasedProductIDs.insert(transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}

extension StoreManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.fetchedProducts = response.products
        }
    }
}


extension StoreManager {
    func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
        for download in downloads {
            let productID = download.contentIdentifier
            
            switch download.downloadState {
            case .active:
                DispatchQueue.main.async {
                    // Cast to Double to match @Published var downloadProgress: [String: Double]
                    self.downloadProgress[productID] = Double(download.progress)
                }
            case .finished:
                processFinishedDownload(download)
                DispatchQueue.main.async {
                    self.downloadProgress.removeValue(forKey: productID)
                }
            case .failed, .cancelled:
                DispatchQueue.main.async {
                    self.downloadProgress.removeValue(forKey: productID)
                }
                SKPaymentQueue.default().finishTransaction(download.transaction)
            case .waiting:
                // Mirroring IAPHelper.m:228 - Force start if waiting
                SKPaymentQueue.default().start([download])
            default:
                break
            }
        }
    }
    
    private func processFinishedDownload(_ download: SKDownload) {
        guard let sourceURL = download.contentURL?.appendingPathComponent("Contents") else { return }
        guard let destinationURL = purchasedContentPath else { return }
        
        let fileManager = FileManager.default
        
        do {
            // Create destination directory: Documents/CombatMMA/[appname]/purchased_content
            try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true)
            
            // Get contents of the downloaded 'Contents' folder
            let items = try fileManager.contentsOfDirectory(atPath: sourceURL.path)
            
            for item in items {
                let sourceFile = sourceURL.appendingPathComponent(item)
                let destFile = destinationURL.appendingPathComponent(item)
                
                // If file already exists, remove it before copying new version
                if fileManager.fileExists(atPath: destFile.path) {
                    try fileManager.removeItem(at: destFile)
                }
                
                try fileManager.copyItem(at: sourceFile, to: destFile)
                print("✅ Moved asset: \(item) to \(destFile.path)")
            }
            
            // Finalize the transaction
            SKPaymentQueue.default().finishTransaction(download.transaction)
            
            // Refresh purchase state to unlock the UI
            loadPurchasedStates()
            
        } catch {
            print("❌ File move error: \(error)")
        }
    }
}
