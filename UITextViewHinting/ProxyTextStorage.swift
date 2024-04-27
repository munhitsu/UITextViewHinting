//
//  ProxyNSTextStorage.swift
//  UITextViewHinting
//
//  Created by Mateusz Łapsa-Malawski on 12/04/2024.
//

import Foundation
import SwiftUI

import OSLog
private let logger = Logger(subsystem: "UITextViewHinting", category: "ProxyNSTextStorage")

extension NSAttributedString.Key {
    static let hidden: NSAttributedString.Key = .init("hidden")
}

class ProxyTextStorage: NSTextStorage {
    private var data:NSMutableAttributedString // also works proxying to NSTextStorage
    
    
    override init() {
        data = NSMutableAttributedString()
        super.init()
    }

    override init(string: String) {
        data = NSMutableAttributedString(string: string)
        super.init()
    }

    override init(attributedString: NSAttributedString) {
        data = NSMutableAttributedString(attributedString: attributedString)
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var string: String { // this gets called all the time - make sure it's cheap
        return data.string
    }

    override func replaceCharacters(in range: NSRange, with str: String) {
        beginEditing()
        data.replaceCharacters(in: range, with: str)
        edited(.editedCharacters, range: range, changeInLength: str.count - range.length)
        endEditing()
    }
    
    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        return data.attributes(at: location, effectiveRange: range)
    }

    override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        beginEditing()
        data.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
}

extension ProxyTextStorage: NSTextContentManagerDelegate {
    /// This will hide NSTextElement with attribute "hidden"
    /// note this example will crash on edit - don't know why
    func textContentManager(_ textContentManager: NSTextContentManager,
                            shouldEnumerate textElement: NSTextElement,
                            options: NSTextContentManager.EnumerationOptions) -> Bool {
        // The text content manager calls this method to determine whether each text element should be enumerated for layout.
        // To hide comments, tell the text content manager not to enumerate this element if it's a comment.
        if let paragraph = textElement as? NSTextParagraph, let _ = paragraph.attributedString.attribute(.hidden, at: 0, effectiveRange: nil) {
            return false
        } else {
            return true
        }
    }
}

extension ProxyTextStorage: NSTextContentStorageDelegate {
    
    /// This appends _123 to every not empty line
    func textContentStorage(_ textContentStorage: NSTextContentStorage, textParagraphWith range: NSRange) -> NSTextParagraph? {
        let orgText = textContentStorage.textStorage!.attributedSubstring(from: range)
        let hintAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.lightGray]
        let hintText = NSAttributedString(string: " 123", attributes: hintAttributes)
        let extendedText = NSMutableAttributedString(attributedString: orgText)
                
        let lastCharacterIndex = extendedText.length - 1
        
        if lastCharacterIndex == 0 {
            extendedText.append(hintText)
        } else {
            let lastCharacter = extendedText.string[extendedText.string.index(extendedText.string.startIndex, offsetBy: lastCharacterIndex)]
            if lastCharacter != "\n" {
                extendedText.append(hintText)
            } else {
                extendedText.insert(hintText, at: extendedText.length-1)
            }
        }
        
        let paragraph = NSTextParagraph(attributedString: extendedText)
        return paragraph
    }
}


