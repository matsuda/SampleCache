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
    private let diskCache: DiskCache?
    private var memoryCache: [String: LinkedList<String, UIImage>.Node]
    private let list: LinkedList<String, UIImage>

    init(limitCount: Int = 10,
         diskCache: DiskCache? = .default) {
        self.limitCount = limitCount
        self.diskCache = diskCache

        self.memoryCache = [String: LinkedList<String, UIImage>.Node](minimumCapacity: limitCount)
        self.list = .init()

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

        memoryCache.removeAll()
        list.removeAll()
        #if DEBUG
        print("list:", list)
        print("memoryCache:", memoryCache)
        #endif
    }

    func image(forKey key: String) -> UIImage? {
        // print("-----------<", #function, ">---------------")
        guard let cachedKey = key.md5 else { return nil }
        // print("cachedKey:", cachedKey)

        var image: UIImage?
        concurrentQueue.sync {
            if let node = self.memoryCache[cachedKey] {
                // print("node:", node)
                image = node.value
                list.remove(node)
                list.addToHead(node)
            } else if let data = diskCache?.get(forKey: cachedKey),
                let cachedImage = UIImage(data: data) {
                // print("cachedImage:", cachedImage)
                image = cachedImage
                store(image: cachedImage, forKey: key)
            }
            #if DEBUG
            print("list:", list)
            print("memoryCache:", memoryCache)
            #endif
        }
        return image
    }

    func store(image: UIImage, forKey key: String) {
        // print("-----------<", #function, ">---------------")
        guard let cachedKey = key.md5 else { return }
        // print("cachedKey:", cachedKey)

        concurrentQueue.async(flags: .barrier) {
            if let node = self.memoryCache[cachedKey] {
                // print("node:", node)
                node.value = image
                self.list.remove(node)
                self.list.addToHead(node)
                #if DEBUG
                print("list:", self.list)
                print("memoryCache:", self.memoryCache)
                #endif
                return
            }

            if self.memoryCache.count >= self.limitCount {
                if let node = self.list.tail {
                    // print("node:", node)
                    let lastImage = node.value
                    self.memoryCache.removeValue(forKey: node.key)
                    self.list.remove(node)
                    if let diskCache = self.diskCache {
                        if let data = lastImage.pngData() {
                            diskCache.set(data, forKey: node.key)
                        } else if let data = lastImage.jpegData(compressionQuality: 1.0) {
                            diskCache.set(data, forKey: node.key)
                        }
                    }
                }
            }
            let node = self.list.createNode(key: cachedKey, value: image)
            self.memoryCache[cachedKey] = node
            self.list.addToHead(node)
            #if DEBUG
            print("list:", self.list)
            print("memoryCache:", self.memoryCache)
            #endif
        }
    }
}
