//
//  DiskCache.swift
//  SampleCache
//
//  Created by Kosuke Matsuda on 2020/03/21.
//  Copyright © 2020 Kosuke Matsuda. All rights reserved.
//

import Foundation

class DiskCache {
    private let cacheDir: String
    private let fm: FileManager

    class var `default`: DiskCache {
        return DiskCache(name: "com.github.matsuda.SampleCache")
    }

    init(name: String) {
        fm = FileManager()
        cacheDir = (DiskCache.cacheDirectory() as NSString).appendingPathComponent(name)
        try? fm.createDirectory(atPath: cacheDir, withIntermediateDirectories: true, attributes: nil)
    }

    func get(forKey key: String) -> Data? {
        let path = (cacheDir as NSString).appendingPathComponent(key)
        guard fm.fileExists(atPath: path) else { return nil }
        guard let data = fm.contents(atPath: path) else { return nil }
        return data
    }

    func set(_ data: Data, forKey key: String) {
        let path = (cacheDir as NSString).appendingPathComponent(key)
        if fm.fileExists(atPath: path) {
            try? fm.removeItem(atPath: path)
        }
        fm.createFile(atPath: path, contents: data, attributes: nil)
    }

    class func cacheDirectory() -> String {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    }
}
