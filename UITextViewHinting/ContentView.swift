//
//  ContentView.swift
//  UITextViewHinting
//
//  Created by Mateusz Łapsa-Malawski on 27/04/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    
    private var proxyTextStorage: ProxyTextStorage
    
    init() {
        let str = NSMutableAttributedString(string: "Immutable title\n")
        str.append(NSAttributedString(string: "line 2 hidden\n", attributes: [.hidden: true]))
        str.append(NSAttributedString(string: "line 3 substring"))
        self.proxyTextStorage = ProxyTextStorage(attributedString: str)
    }
    
    var body: some View {
        DocumentTextView(textStorage: proxyTextStorage)
    }
    
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
