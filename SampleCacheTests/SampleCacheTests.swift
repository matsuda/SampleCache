//
//  SampleCacheTests.swift
//  SampleCacheTests
//
//  Created by Kosuke Matsuda on 2020/03/15.
//  Copyright © 2020 Kosuke Matsuda. All rights reserved.
//

import XCTest
@testable import SampleCache

class SampleCacheTests: XCTestCase {

    private let diskCacheName = "cache_test"
    private lazy var images: [String] = self.loadImages()
    private let fm: FileManager = .default

    override func setUp() {
        super.setUp()
        let cacheDir = self.cacheDir(name: diskCacheName)
        try? fm.removeItem(atPath: cacheDir)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testCache() {
        let diskCache = DiskCache(name: diskCacheName)
        let cache = LRUImageCache(limitCount: 3, diskCache: diskCache)
        let cacheDir = self.cacheDir(name: diskCacheName)

        let image0path = images[0]
        let image0 = UIImage(contentsOfFile: image0path)!
        cache.store(image: image0, forKey: image0path)
        // [0]
        XCTAssert(cache.image(forKey: image0path) != nil)

        let image0key = image0path.md5!
        let image0cache = (cacheDir as NSString).appendingPathComponent(image0key)
        XCTAssert(fm.fileExists(atPath: image0cache) == false)

        let image1path = images[1]
        let image1 = UIImage(contentsOfFile: image1path)!
        cache.store(image: image1, forKey: image1path)
        // [1,0]
        XCTAssert(cache.image(forKey: image1path) != nil)
        XCTAssert(fm.fileExists(atPath: image0cache) == false)

        let image2path = images[2]
        let image2 = UIImage(contentsOfFile: image2path)!
        cache.store(image: image2, forKey: image2path)
        // [2,1,0]
        XCTAssert(cache.image(forKey: image2path) != nil)
        XCTAssert(fm.fileExists(atPath: image0cache) == false)

        let image3path = images[3]
        XCTAssert(cache.image(forKey: image3path) == nil)

        let image3 = UIImage(contentsOfFile: image3path)!
        cache.store(image: image3, forKey: image3path)
        // [3,2,1]
        XCTAssert(cache.image(forKey: image3path) != nil)
        XCTAssert(fm.fileExists(atPath: image0cache) == true)

        // [1,3,2]
        XCTAssert(cache.image(forKey: image1path) != nil)

        let image1key = image1path.md5!
        let image1cache = (cacheDir as NSString).appendingPathComponent(image1key)
        XCTAssert(fm.fileExists(atPath: image1cache) == false)

        let image2key = image2path.md5!
        let image2cache = (cacheDir as NSString).appendingPathComponent(image2key)
        XCTAssert(fm.fileExists(atPath: image2cache) == false)

        let image4path = images[4]
        let image4 = UIImage(contentsOfFile: image4path)!
        cache.store(image: image4, forKey: image4path)
        // [4,1,3]
        XCTAssert(cache.image(forKey: image3path) != nil)
        XCTAssert(fm.fileExists(atPath: image1cache) == false)
        XCTAssert(fm.fileExists(atPath: image2cache) == true)
    }

    func testThread() {
        let cache = LRUImageCache(limitCount: 3, diskCache: nil)

        let exp = expectation(description: "test thread")
        exp.expectedFulfillmentCount = 2

        let queue1 = DispatchQueue(label: "cache.test.1")
        let queue2 = DispatchQueue(label: "cache.test.2")

        queue1.async {
            // [2,1,0]
            (0..<3).forEach { i in
                let key = self.images[i]
                let image = UIImage(contentsOfFile: key)!
                cache.store(image: image, forKey: key)
                XCTAssert(cache.image(forKey: key) != nil)
            }
            exp.fulfill()
        }

        queue2.async {
            // [5,4,3]
            (3..<6).forEach { i in
                let key = self.images[i]
                let image = UIImage(contentsOfFile: key)!
                cache.store(image: image, forKey: key)
                XCTAssert(cache.image(forKey: key) != nil)
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5)

        let count = (0..<6).reduce(0) { (total, i) -> Int in
            if cache.image(forKey: images[i]) == nil {
                return total
            }
            return total + 1
        }
        XCTAssert(count == 3)
    }
}

extension SampleCacheTests {
    private func loadImages() -> [String] {
        let names = [
            "backpack.png",
            "kyoto.jpg",
            "map.png",
            "pet.jpg",
            "sushi.jpg",
            "ticket.png",
            "vr.jpg",
        ]
        return names.map {
            Bundle(for: type(of: self)).path(forResource: $0, ofType: nil)!
        }
    }

    private func cacheDir(name: String) -> String {
        let dir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        return (dir as NSString).appendingPathComponent(name)
    }
}
