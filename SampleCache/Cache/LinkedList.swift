//
//  LinkedList.swift
//  SampleCache
//
//  Created by Kosuke Matsuda on 2020/03/23.
//  Copyright © 2020 Kosuke Matsuda. All rights reserved.
//

import Foundation

final class LinkedList<Key, Value> {
    final class Node {
        weak var prev: Node?
        var next: Node?
        var key: Key
        var value: Value

        init(key: Key, value: Value) {
            self.key = key
            self.value = value
        }
    }

    var head: Node?
    var tail: Node?

    init() {}

    func createNode(key: Key, value: Value) -> Node {
        return Node(key: key, value: value)
    }

    func addToHead(_ node: Node) {
        if let head = self.head {
            head.prev = node
            node.next = head
            self.head = node
        } else {
            head = node
            tail = node
        }
    }

    func remove(_ node: Node) {
        node.next?.prev = node.prev
        node.prev?.next = node.next
        if node === head {
            head = node.next
        }
        if node === tail {
            tail = node.prev
        }
        node.prev = nil
        node.next = nil
    }

    func removeAll() {
        var node = head
        while let next = node?.next {
            node?.next = nil
            next.prev = nil
            node = next
        }
        head = nil
        tail = nil
    }
}


extension LinkedList: CustomStringConvertible {
    var description: String {
        var texts: [String] = []
        var next = head
        while let node = next {
            texts.append("\(node)")
            next = node.next
        }
        return "<\(type(of: self))["
            + (texts.isEmpty ? "" :  "\n  " + texts.joined(separator: ",\n  ") + "\n")
            + "]>"
    }
}

extension LinkedList.Node: CustomStringConvertible {
    var description: String {
        var texts: [String] = []
        texts.append("key = (\(key))")
        // texts.append("value = (\(value))")
        if let prev = prev {
            texts.append("prev = (\(prev.key))")
        }
        if let next = next {
            texts.append("next = (\(next.key))")
        }
        return "<\(type(of: self)): "
            + (texts.isEmpty ? "" :  texts.joined(separator: "; "))
            + ">"
    }
}
