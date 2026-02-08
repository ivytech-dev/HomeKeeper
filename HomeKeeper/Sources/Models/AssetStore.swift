import Foundation
import SwiftUI

class AssetStore: ObservableObject {
    @Published var assets: [Asset] = []

    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("HomeKeeper", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("assets.json")
    }()

    init() {
        load()
    }

    // MARK: - CRUD

    func add(_ asset: Asset) {
        assets.append(asset)
        save()
    }

    func update(_ asset: Asset) {
        guard let index = assets.firstIndex(where: { $0.id == asset.id }) else { return }
        assets[index] = asset
        save()
    }

    func retire(_ id: UUID) {
        guard let index = assets.firstIndex(where: { $0.id == id }) else { return }
        assets[index].isRetired = true
        assets[index].retiredDate = Date()
        save()
    }

    func delete(_ id: UUID) {
        assets.removeAll { $0.id == id }
        save()
    }

    // MARK: - Summary

    var activeAssets: [Asset] { assets.filter { !$0.isRetired } }
    var retiredAssets: [Asset] { assets.filter { $0.isRetired } }
    var totalCost: Int { activeAssets.reduce(0) { $0 + $1.purchasePrice } }
    var overUsefulLifeCount: Int { activeAssets.filter { $0.isOverUsefulLife }.count }

    // MARK: - Persistence

    private func save() {
        do {
            let data = try JSONEncoder().encode(assets)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Save error: \(error.localizedDescription)")
        }
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            assets = try JSONDecoder().decode([Asset].self, from: data)
        } catch {
            print("Load error: \(error.localizedDescription)")
        }
    }
}
