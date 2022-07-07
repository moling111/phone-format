//
//  GlobalExtension.swift
//  swiftdemo
//
//  Created by gzj on 2022/7/7.
//  Copyright © 2022 zengzuo. All rights reserved.
//

import Foundation

extension String {
    
    func substring(from: Int) -> String? {
        let length = self.count - from
        return substring(from: from, length: length)
    }
    
    func substring(to: Int) -> String? {
        return substring(from: 0, length: to)
    }
    
    func substring(from: Int, length: Int) -> String? {
        guard from >= 0, from < self.count else {
            return nil
        }
        guard length > 0, length <= self.count else {
            return nil
        }
        guard from + length <= self.count else {
            return nil
        }
        let startIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(self.startIndex, offsetBy: from + length)
        return String(self[startIndex ..< endIndex])
    }
    
}
