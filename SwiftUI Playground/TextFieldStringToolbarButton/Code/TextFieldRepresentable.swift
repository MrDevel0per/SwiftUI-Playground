//
//  TextFieldRepresentable.swift
//  SwiftUI Playground
//
//  Created by Owen Cruz-Abrams on 2/26/23.
//

import Foundation
import AppKit
import SwiftUI

struct TextFieldRepresentable: NSViewRepresentable{
    
    
    ///This is an `NSTextField` for use in SwiftUI
    typealias NSViewType = NSTextField
    
    ///The placeholder to be displayed when `text` is empty
    var placeholder: String = ""
    
    ///This is the text that the `TextFieldRepresentable` will display and change.
    @Binding var text: String
    
    
    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        //Set the placeholder for when there is no text
        textField.placeholderString = placeholder
        //Set the TextField delegate
        textField.delegate = context.coordinator
        DispatchQueue.main.async{
            //Run all the time to check current cursor location
            _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { time in
                if let editor = textField.currentEditor(){
                    TextHolder.shared.selectedRange = editor.selectedRange
                } else {
                    print("Error")
                }
            }
        }
        
        return textField
    }
    
    func updateNSView(_ nsView: NSTextField, context: Context) {
        //Update the actual TextField
        nsView.stringValue = text
        
        DispatchQueue.main.async {
            //Move the cursor forward one if SwiftUI just changed the value
            if TextHolder.shared.justChanged{
                nsView.currentEditor()?.selectedRange.location += 1
                TextHolder.shared.justChanged = false
            }
        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: TextFieldRepresentable
        
        init(_ parent: TextFieldRepresentable) {
            self.parent = parent
        }
        
        func controlTextDidChange(_ obj: Notification) {
            //To avoid the "NSHostingView is being laid out reentrantly while rendering its SwiftUI content." error
            DispatchQueue.main.async {
                
                
                //Ensure we can get the current editor
                //If not, handle the error appropriately
                if let textField = obj.object as? NSTextField, let editor = textField.currentEditor(){
                    //Update the parent's text, so SwiftUI knows the new value
                    self.parent.text = textField.stringValue
                    //Set the property
                    TextHolder.shared.selectedRange = editor.selectedRange
                } else {
                    //Handle errors - we could not get the editor
                    print("Could not get the current editor")
                }
            }
        }
    }
    
}


