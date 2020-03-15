//
//  LRUImageCache.swift
//  SampleCache
//
//  Created by Kosuke Matsuda on 2020/03/15.
//  Copyright © 2020 Kosuke Matsuda. All rights reserved.
//

import Foundation
import UIKit

final class LRUImageCache {
    private let concurrentQueue = DispatchQueue(label: "com.github.matsuda.SampleCache", qos: .default, attributes: .concurrent)
    private let limitCount: Int
    private let memoryCache: NSCache<NSString, UIImage>
    private let diskCache: DiskCache
    private var cachedKeysInMemory: [String] = []

    init(limitCount: Int = 10,
         memoryCache: NSCache<NSString, UIImage> = .init(),
         diskCache: DiskCache = .default) {
        self.limitCount = limitCount
        self.memoryCache = memoryCache
        self.diskCache = diskCache

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveMemoryWarning(_:)),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func didReceiveMemoryWarning(_ notification: Notification) {
        print("didReceiveMemoryWarning")
        memoryCache.removeAllObjects()
        cachedKeysInMemory.removeAll()
    }

    func image(forKey key: String) -> UIImage? {
        guard let cachedKey = key.md5 else { return nil }

        var image: UIImage?
        concurrentQueue.sync {
            if let cachedImage = self.memoryCache.object(forKey: cachedKey as NSString) {
                image = cachedImage
                self.updateCachedKeysInMemory(key: cachedKey)
            } else if let data = self.diskCache.data(forKey: cachedKey),
                let cachedImage = UIImage(data: data) {
                image = cachedImage
                self.store(image: cachedImage, forKey: key)
            }
        }
        return image
    }

    func store(image: UIImage, forKey key: String) {
        guard let cachedKey = key.md5 else { return }
        print("oooooooo >>>>>>>>", cachedKey)

        concurrentQueue.async(flags: .barrier) {
            if let _ = self.memoryCache.object(forKey: cachedKey as NSString) {
                self.updateCachedKeysInMemory(key: cachedKey)
                return
            }

            if self.cachedKeysInMemory.count >= self.limitCount {
                let lastKey = self.cachedKeysInMemory.removeLast()
                print("rrrrrrrrr >>>>>>>>", lastKey)
                if let lastImage = self.memoryCache.object(forKey: lastKey as NSString) {
                    if let data = lastImage.pngData() {
                        self.diskCache.setData(data, forKey: lastKey)
                    } else if let data = lastImage.jpegData(compressionQuality: 1.0) {
                        self.diskCache.setData(data, forKey: lastKey)
                    }
                }
                self.memoryCache.removeObject(forKey: lastKey as NSString)
            }

            self.memoryCache.setObject(image, forKey: cachedKey as NSString)
            self.cachedKeysInMemory.insert(cachedKey, at: 0)
            print("ttttttttt >>>>>>>", self.cachedKeysInMemory)
        }
    }

    private func updateCachedKeysInMemory(key: String) {
        if let index = cachedKeysInMemory.firstIndex(of: key) {
            cachedKeysInMemory.remove(at: index)
        }
        cachedKeysInMemory.insert(key, at: 0)
        print("vvvvvvv >>>>>>>", cachedKeysInMemory)
    }
}
