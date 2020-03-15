//
//  String+Extensions.swift
//  SampleCache
//
//  Created by Kosuke Matsuda on 2020/03/21.
//  Copyright © 2020 Kosuke Matsuda. All rights reserved.
//

import Foundation
import CommonCrypto

extension String {
    var md5: String? {
        let digestLength = Int(CC_MD5_DIGEST_LENGTH)
        guard let messageData = self.data(using: .utf8) else { return nil }
        var digestData = Data(count: digestLength)
        _ = digestData.withUnsafeMutableBytes { (digestBytes) -> UInt8 in
            messageData.withUnsafeBytes { (messageBytes) -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress,
                    let digestBytesBlindMemmory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemmory)
                }
                return 0
            }
        }
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
}
