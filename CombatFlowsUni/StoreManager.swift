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
import ZIPFoundation

class StoreManager: NSObject, ObservableObject {
    @Published var fetchedProducts: [SKProduct] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isRestoring: Bool = false
    @Published var downloadProgress: [String: Double] = [:]
    @Published var favoriteProductIDs: Set<String> = []
    
    let bundleID = "ca.ilearningsolutions.combatflows.combatflowbundle"
    private var productsRequest: SKProductsRequest?
    var curriculumStore: CurriculumStore?
    
    let downloadBaseURL = "https://pub-56b90c5a6a374b999e76b568fdd359d0.r2.dev/iap/"

    let downloadMap = [
        "ca.ilearningsolutions.combatflows.combatflow01": "01-combatflow-1.zip",
        "ca.ilearningsolutions.combatflows.combatflow02": "02-combatflow-1.zip",
        "ca.ilearningsolutions.combatflows.combatflow03": "03-combatflow-1.zip",
        "ca.ilearningsolutions.combatflows.combatflow04": "04-combatflow-1.zip",
        "ca.ilearningsolutions.combatflows.combatflow05": "05-combatflow-1.zip",
        "ca.ilearningsolutions.combatflows.combatflow06": "06-combatflow-1.zip",
        "ca.ilearningsolutions.combatflows.combatflow07": "07-combatflow-1.zip",
        "ca.ilearningsolutions.combatflows.combatflow08": "08-combatflow-1.zip",
        "ca.ilearningsolutions.combatflows.combatflow09": "09-combatflow-1.zip",
        "ca.ilearningsolutions.combatflows.combatflow10": "10-combatflow-1.zip",
        "ca.ilearningsolutions.combatflows.combatflow11": "11-combatflow-1.zip",
        "ca.ilearningsolutions.combatflows.combatflow12": "12-combatflow-1.zip",
        "ca.ilearningsolutions.combatflows.combatflow13": "13-combatflow-1.zip",
        "ca.ilearningsolutions.combatflows.combatflow14": "14-combatflow-1.zip",
        "ca.ilearningsolutions.combatflows.combatflow15": "15-combatflow-1.zip",
        "ca.ilearningsolutions.combatflows.combatflow16": "16-combatflow-1.zip",
        "ca.ilearningsolutions.combatflows.combatflowbundle": "combatflowbundle.zip"
    ]
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        loadFavorites()
    }
    
    func initializePurchases(with store: CurriculumStore) {
        self.curriculumStore = store
        loadPurchasedStates()
    }
    
    func loadPurchasedStates() {
        guard let store = curriculumStore else { return }
        var newlyPurchasedIDs = Set<String>()
        
        for group in store.flowGroups {
            if hasPurchasedFiles(for: group.productIdentifier) || UserDefaults.standard.bool(forKey: group.productIdentifier) {
                newlyPurchasedIDs.insert(group.productIdentifier)
            }
        }
        
        if hasPurchasedFiles(for: bundleID) || UserDefaults.standard.bool(forKey: bundleID) {
            newlyPurchasedIDs.insert(bundleID)
        }
        
        DispatchQueue.main.async {
            self.purchasedProductIDs = newlyPurchasedIDs
        }
    }

    // MARK: - File Verification Logic
    private var purchasedContentPath: URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentsDirectory = paths.first else { return nil }
        return documentsDirectory.appendingPathComponent("CombatMMA/combatflows/purchased_content")
    }
    
    private func hasPurchasedFiles(for productID: String) -> Bool {
        guard let contentPath = purchasedContentPath, let store = curriculumStore else { return false }
        let fileManager = FileManager.default
        guard let purchasedFiles = try? fileManager.contentsOfDirectory(atPath: contentPath.path) else { return false }
        let purchasedSet = Set(purchasedFiles)
        
        let requiredAssets = getRequiredAssets(for: productID, from: store)
        if requiredAssets.isEmpty { return false }
        
        return Set(requiredAssets).isSubset(of: purchasedSet)
    }
    
    private func getRequiredAssets(for productID: String, from store: CurriculumStore) -> [String] {
        guard let group = store.flowGroups.first(where: { $0.productIdentifier == productID }) else { return [] }
        return group.combatFlows.flatMap { $0.lessons.map { $0.filename } }
    }

    // MARK: - StoreKit Actions
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

// MARK: - SKPaymentTransactionObserver
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
        UserDefaults.standard.set(true, forKey: productID)
        
        // 1. Mark as purchased locally
        DispatchQueue.main.async { self.purchasedProductIDs.insert(productID) }
        
        // 2. Start the R2 Download
        startManualDownload(for: productID)
        
        // 3. Finish transaction immediately (since we aren't using SKDownload)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func handleRestored(_ transaction: SKPaymentTransaction) {
        let productID = transaction.payment.productIdentifier
        UserDefaults.standard.set(true, forKey: productID)
        
        DispatchQueue.main.async { self.purchasedProductIDs.insert(productID) }
        
        // If the files aren't on disk, download them
        if !hasPurchasedFiles(for: productID) {
            startManualDownload(for: productID)
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func handleFailed(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        DispatchQueue.main.async { self.isRestoring = false }
    }
}

// MARK: - R2 Download Logic
extension StoreManager: URLSessionDownloadDelegate {
    
    func startManualDownload(for productID: String) {
        guard let fileName = downloadMap[productID],
              let url = URL(string: downloadBaseURL + fileName) else { return }
        
        print("🚀 Starting R2 Download: \(url.absoluteString)")
        
        // Create a session that allows us to track progress
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        let task = session.downloadTask(with: url)
        task.taskDescription = productID // Pass ID to the delegate
        task.resume()
    }
    
    // Track Progress
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let productID = downloadTask.taskDescription else { return }
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        
        DispatchQueue.main.async {
            self.downloadProgress[productID] = progress
        }
    }
    
    // Download Finished
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let productID = downloadTask.taskDescription,
              let destinationFolder = purchasedContentPath else { return }
        
        let fileManager = FileManager.default
        let zipDestination = destinationFolder.appendingPathComponent("\(productID).zip")
        
        do {
            try fileManager.createDirectory(at: destinationFolder, withIntermediateDirectories: true)
            
            if fileManager.fileExists(atPath: zipDestination.path) {
                try fileManager.removeItem(at: zipDestination)
            }
            
            try fileManager.moveItem(at: location, to: zipDestination)
            
            // Perform Unzip
            unzipDownloadedContent(at: zipDestination, to: destinationFolder)
            
            // Cleanup
            try fileManager.removeItem(at: zipDestination)
            
            print("✅ Successfully installed \(productID)")
            
            DispatchQueue.main.async {
                self.downloadProgress.removeValue(forKey: productID)
                self.loadPurchasedStates()
                
                // Diagnostic
                if let path = self.purchasedContentPath?.path {
                    let files = (try? FileManager.default.contentsOfDirectory(atPath: path)) ?? []
                    print("📁 Current Purchased Content Directory: \(files)")
                }
            }
            
        } catch {
            print("❌ File handling error: \(error)")
        }
    }
    
    private func unzipDownloadedContent(at zipURL: URL, to destinationURL: URL) {
        print("📦 Unzipping items to: \(destinationURL.path)")
        
        let fileManager = FileManager.default
        
        do {
            // This requires the ZIPFoundation library
            // If you haven't added it: File > Add Packages > https://github.com/weichsel/ZIPFoundation.git
            try fileManager.unzipItem(at: zipURL, to: destinationURL)
            
            // DEBUG: List the files to verify they are actually there now
            let items = try fileManager.contentsOfDirectory(atPath: destinationURL.path)
            print("🗂 Files extracted: \(items)")
            
        } catch {
            print("❌ Unzip Failed: \(error.localizedDescription)")
        }
    }
}

// MARK: - SKProductsRequestDelegate
extension StoreManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async { self.fetchedProducts = response.products }
    }
}

// MARK: - Favorites
extension StoreManager {
    func toggleFavorite(for productID: String) {
        if favoriteProductIDs.contains(productID) {
            favoriteProductIDs.remove(productID)
        } else {
            favoriteProductIDs.insert(productID)
        }
        UserDefaults.standard.set(Array(favoriteProductIDs), forKey: "favorite_flows")
    }

    func loadFavorites() {
        let saved = UserDefaults.standard.stringArray(forKey: "favorite_flows") ?? []
        self.favoriteProductIDs = Set(saved)
    }
}
