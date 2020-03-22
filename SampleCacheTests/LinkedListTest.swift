//
//  LinkedListTest.swift
//  SampleCacheTests
//
//  Created by Kosuke Matsuda on 2020/03/29.
//  Copyright © 2020 Kosuke Matsuda. All rights reserved.
//

import XCTest
@testable import SampleCache

class LinkedListTest: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testAddToHead() {
        let list: LinkedList<Int, String> = .init()

        let node1 = list.createNode(key: 1, value: "value1")
        list.addToHead(node1)
        XCTAssert(list.head === node1)
        XCTAssert(list.tail === node1)
        XCTAssert(node1.prev === nil)
        XCTAssert(node1.next === nil)

        let node2 = list.createNode(key: 2, value: "value2")
        list.addToHead(node2)
        XCTAssert(list.head === node2)
        XCTAssert(list.tail === node1)
        XCTAssert(node2.prev === nil)
        XCTAssert(node2.next === node1)
        XCTAssert(node1.prev === node2)
        XCTAssert(node1.next === nil)

        let node3 = list.createNode(key: 3, value: "value3")
        list.addToHead(node3)
        XCTAssert(list.head === node3)
        XCTAssert(list.tail === node1)
        XCTAssert(node3.prev === nil)
        XCTAssert(node3.next === node2)
        XCTAssert(node2.prev === node3)
        XCTAssert(node2.next === node1)
        XCTAssert(node1.prev === node2)
        XCTAssert(node1.next === nil)
    }

    func testRemoveHead() {
        let list: LinkedList<String, Int> = .init()
        let node1: LinkedList<String, Int>.Node = .init(key: "key1", value: 1)
        list.addToHead(node1)
        let node2: LinkedList<String, Int>.Node = .init(key: "key2", value: 2)
        list.addToHead(node2)
        let node3: LinkedList<String, Int>.Node = .init(key: "key3", value: 3)
        list.addToHead(node3)

        list.remove(node3)
        XCTAssert(list.head === node2)
        XCTAssert(node2.next === node1)
        XCTAssert(node1.prev === node2)
        XCTAssert(list.tail === node1)
        XCTAssert(node3.prev === nil)
        XCTAssert(node3.next === nil)
    }

    func testRemoveTail() {
        let list: LinkedList<String, Int> = .init()
        let node1 = list.createNode(key: "key1", value: 1)
        list.addToHead(node1)
        let node2 = list.createNode(key: "key2", value: 2)
        list.addToHead(node2)
        let node3 = list.createNode(key: "key3", value: 3)
        list.addToHead(node3)

        list.remove(node1)
        XCTAssert(list.head === node3)
        XCTAssert(node3.next === node2)
        XCTAssert(node2.prev === node3)
        XCTAssert(list.tail === node2)
        XCTAssert(node1.prev === nil)
        XCTAssert(node1.next === nil)
    }

    func testRemoveMiddle() {
        let list: LinkedList<String, Int> = .init()
        let node1 = list.createNode(key: "key1", value: 1)
        list.addToHead(node1)
        let node2 = list.createNode(key: "key2", value: 2)
        list.addToHead(node2)
        let node3 = list.createNode(key: "key3", value: 3)
        list.addToHead(node3)

        list.remove(node2)
        XCTAssert(list.head === node3)
        XCTAssert(node3.next === node1)
        XCTAssert(node1.prev === node3)
        XCTAssert(list.tail === node1)
        XCTAssert(node2.prev === nil)
        XCTAssert(node2.next === nil)
    }

    func testRemoveAll() {
        let list: LinkedList<String, Int> = .init()
        let node1 = list.createNode(key: "key1", value: 1)
        list.addToHead(node1)
        let node2 = list.createNode(key: "key2", value: 2)
        list.addToHead(node2)
        let node3 = list.createNode(key: "key3", value: 3)
        list.addToHead(node3)

        list.removeAll()
        XCTAssert(list.head === nil)
        XCTAssert(list.tail === nil)
    }
}
