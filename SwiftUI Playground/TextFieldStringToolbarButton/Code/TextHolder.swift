//
//  TextHolder.swift
//  SwiftUI Playground
//
//  Created by Owen Cruz-Abrams on 2/26/23.
//

import Foundation
import SwiftUI
import AppKit

class TextHolder: ObservableObject{
    ///The shared instance of `TextHolder` for access across the frameworks.
    public static let shared = TextHolder()
    
    ///The currently user selected text range.
    @Published var selectedRange: NSRange? = nil
    
    ///Whether or not SwiftUI just changed the text
    @Published var justChanged = false
}
