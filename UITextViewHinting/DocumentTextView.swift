//
//  DocumentTextView.swift
//  UITextViewHinting
//
//  Created by Mateusz Łapsa-Malawski on 12/04/2024.
//

import Foundation
import SwiftUI

import OSLog
private let logger = Logger(subsystem: "UITextViewHinting", category: "DocumentTextView")


@MainActor struct DocumentTextView: UIViewRepresentable {

    var textStorage: ProxyTextStorage
    
    func makeUIView(context: Context) -> UITextView {
        let textLayoutManager = NSTextLayoutManager()
        let textContainer = NSTextContainer()
        textLayoutManager.textContainer = textContainer
        
        let textContentStorage = NSTextContentStorage()
        textContentStorage.textStorage = textStorage
        textContentStorage.addTextLayoutManager(textLayoutManager)
        textContentStorage.delegate = textStorage
                        
        let textView = UITextView(frame: .infinite, textContainer: textLayoutManager.textContainer)
        textView.delegate = context.coordinator
        
        guard let _ = textView.textLayoutManager else {
            fatalError("We are not in TextKit2 mode")
        }
        
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        textView.isSelectable = true
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        textView.backgroundColor = .white
        context.coordinator.view = textView
        return textView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    /*
     will be triggered by new text in the parent view
     */
    func updateUIView(_ textView: UITextView, context: Context) {
        logger.debug("updateUIView()")
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: DocumentTextView
        var view: UITextView!
        
        init(_ documentTextView: DocumentTextView) {
            self.parent = documentTextView
            super.init()
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            
            let string = (parent.textStorage.string  as NSString)
            let firstLineRange = string.lineRange(for: NSRange(location: 0, length: 0))
            logger.debug("Text is about to change at \(range) to `\(text)`, where firstLine is: \(firstLineRange)")

            if range.location < firstLineRange.length {
                return false
            } else {
                return true
            }
        }
        
        /*
         is executed on every character change
         in response to user-initiated changes to the text
         */
        func textViewDidChange(_ textView: UITextView) {
            logger.debug("textViewDidChange")
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            logger.debug("textViewDidBeginEditing")
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            logger.debug("textViewDidEndEditing")
        }
        
        @objc func textStorageDidEndEditing(notification: Notification) {
            logger.debug("textStorageDidEndEditing")
        }
                
        func textViewDidChangeSelection(_ textView: UITextView) {
            logger.debug("textStorageDidEndEditing")
        }
    }
}
