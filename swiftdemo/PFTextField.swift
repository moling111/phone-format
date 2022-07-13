//
//  PFTextField.swift
//  swiftdemo
//
//  Created by gzj on 2022/7/7.
//  Copyright © 2022 zengzuo. All rights reserved.
//

import UIKit

enum TextFieldOperate {
    case none
    case deleteNum
    case deleteWhiteSpace
    case insertNum
    case copyNum
}

typealias CharCountTuple = (whiteSapceCount: Int, numCount: Int)

class PFTextField: UITextField {

    var textDidBeginEditingHandler: ((_ textField: UITextField) -> Void)?
    
    var textDidEndEditingHandler: ((_ textField: UITextField) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        keyboardType = .numberPad
        clearButtonMode = .whileEditing
        delegate = self
    }
}


extension PFTextField: UITextFieldDelegate {
    
    /// 手机号格式: 1xx xxxx xxxx
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self, let text = textField.text {
            var newStr = text
            let isDeleting = range.length > 0 && string.isEmpty
            if isDeleting == true { //删除元素
                if range.length > 1 { return false }
                let deleteIndex = text.index(text.startIndex, offsetBy: range.location)
                let delete = newStr.remove(at: deleteIndex)
                if delete == Character(" ") {
                    setCursorPosition(textField, range: range, operate: .deleteWhiteSpace)
                    return false
                } else {
                    if let formatted = formatNumberString(newStr), newStr != formatted {
                        textField.text = formatted
                        setCursorPosition(textField, range: range, operate: .deleteNum)
                        return false
                    }
                }
            } else {//新增元素首字母只能为“1”
                if text.count >= 13 {
                    setCursorPosition(textField, range: range, operate: .none)
                    return false
                }
                guard let tmpInsertNumStr = getPureNumString(string) else {
                    setCursorPosition(textField, range: range, operate: .none)
                    return false
                }
                let textNumCount = (getPureNumString(text) ?? "").count
                let canInsertCount = 11 - textNumCount
                var insertNumStr: String
                if tmpInsertNumStr.count > canInsertCount {
                    insertNumStr = tmpInsertNumStr.substring(to: canInsertCount) ?? ""
                } else {
                    insertNumStr = tmpInsertNumStr
                }
                let insertIndex = text.index(text.startIndex, offsetBy: range.location)
                newStr.insert(contentsOf: insertNumStr, at: insertIndex)
                if newStr.hasPrefix("1") == false {
                    setCursorPosition(textField, range: range, operate: .none)
                    return false
                }
                
                var operate: TextFieldOperate = .none
                if insertNumStr.count > 1 {
                    operate = .copyNum
                } else if insertNumStr.count == 1 {
                    operate = .insertNum
                }
                if let formatted = formatNumberString(newStr) {
                    if newStr != formatted || string != insertNumStr {
                        textField.text = formatted
                        let addWhiteSpaceCount = formatted.count - text.count - insertNumStr.count
                        let tuple = (whiteSapceCount: addWhiteSpaceCount, numCount: insertNumStr.count)
                        setCursorPosition(textField, range: range, operate: operate, insertCharCountTuple: tuple)
                        return false
                    }
                }
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textDidBeginEditingHandler?(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textDidEndEditingHandler?(textField)
    }
    
}

extension PFTextField {
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) {
            return true
        } else if action == #selector(paste(_:)) {
            return true
        } else {
            return false
        }
    }
    
    fileprivate func getPureNumString(_ number: String) -> String? {
        if number.isEmpty == true { return "" }
        let arrNum: [Character] = ["0","1","2","3","4","5","6","7","8","9"]
        let pureNumText = number.filter { arrNum.contains($0) }
        if pureNumText.isEmpty { return nil }
        return pureNumText
    }
    
    internal func formatNumberString(_ number: String) -> String? {
        guard let tmpPureNumText = getPureNumString(number), tmpPureNumText.isEmpty == false else { return nil }
        var pureNumText: String = ""
        if tmpPureNumText.count > 11 {
            pureNumText = tmpPureNumText.substring(to: 11) ?? ""
        } else {
            pureNumText = tmpPureNumText
        }
        switch pureNumText.count {
        case 0...3:
            break
        case 4...7:
            let index = pureNumText.index(pureNumText.startIndex, offsetBy: 3)
            pureNumText.insert(" ", at: index)
        default:
            let flashbackIndex1 = pureNumText.index(pureNumText.startIndex, offsetBy: 7)
            let flashbackIndex2 = pureNumText.index(pureNumText.startIndex, offsetBy: 3)
            pureNumText.insert(" ", at: flashbackIndex1)
            pureNumText.insert(" ", at: flashbackIndex2)
        }
        return pureNumText
    }
    
    fileprivate func setCursorPosition(_ textField: UITextField, range: NSRange, operate: TextFieldOperate = .deleteWhiteSpace, insertCharCountTuple: CharCountTuple? = nil) {
        guard let inputText = textField.text else { return }
        if range.location < 0 { return }
        switch operate {
        case .deleteWhiteSpace:
            let starting = textField.position(from: textField.beginningOfDocument, offset: range.location)
            guard let start = starting else { return }
            guard let end = textField.position(from: start, offset: 0) else { return }
            textField.selectedTextRange = textField.textRange(from: start, to: end)
        case .copyNum:
            let addNumCount = insertCharCountTuple?.numCount ?? 0
            let beforeCursorLocation = range.location + addNumCount
            var locationBeforeWhiteSapceCount: Int = 0
            for index in 0 ..< range.location {
                let stringIndex = inputText.index(inputText.startIndex, offsetBy: index)
                let inputChar = inputText[stringIndex]
                if inputChar == Character(" ") {
                    locationBeforeWhiteSapceCount += 1
                }
            }
            let whiteSapceCount: Int
            switch beforeCursorLocation - locationBeforeWhiteSapceCount {
            case 0...3: whiteSapceCount = 0
            case 4...7: whiteSapceCount = 1
            default: whiteSapceCount = 2
            }
            let afterCursorLocation = beforeCursorLocation + whiteSapceCount - locationBeforeWhiteSapceCount
            guard let start = textField.position(from: textField.beginningOfDocument, offset: afterCursorLocation) else { return }
            guard let end = textField.position(from: start, offset: 0) else { return }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
                textField.selectedTextRange = textField.textRange(from: start, to: end)
            }
        case .deleteNum:
            if inputText.count == range.location - range.length { return }
            let starting = textField.position(from: textField.beginningOfDocument, offset: range.location)
            guard let start = starting else { return }
            guard let end = textField.position(from: start, offset: 0) else { return }
            textField.selectedTextRange = textField.textRange(from: start, to: end)
        case .insertNum:
            let addWhiteSapceCount = insertCharCountTuple?.whiteSapceCount ?? 0
            let addNumCount = insertCharCountTuple?.numCount ?? 0
            let beforeCursorLocation = range.location + addNumCount
            let lastCursorLocation = beforeCursorLocation + addWhiteSapceCount
            if lastCursorLocation == inputText.count { return }
            if range.location > inputText.count - 1 { return }
            let locationNextIndex = inputText.index(inputText.startIndex, offsetBy: range.location)
            let afterLocationChar = inputText[locationNextIndex]
            let moveWhiteSapceCount = (afterLocationChar == Character(" ")) ? 1 : 0
            let afterCursorLocation = beforeCursorLocation + moveWhiteSapceCount
            guard let start = textField.position(from: textField.beginningOfDocument, offset: afterCursorLocation) else { return }
            guard let end = textField.position(from: start, offset: 0) else { return }
            textField.selectedTextRange = textField.textRange(from: start, to: end)
        default:
            let starting = textField.position(from: textField.beginningOfDocument, offset: range.location)
            guard let start = starting else { return }
            guard let end = textField.position(from: start, offset: 0) else { return }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
                textField.selectedTextRange = textField.textRange(from: start, to: end)
            }
        }
    }
}

