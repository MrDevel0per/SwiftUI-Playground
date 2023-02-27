//
//  ContentView.swift
//  SwiftUI Playground
//
//  Created by Owen Cruz-Abrams on 2/15/23.
//

import SwiftUI

struct TextFieldStringToolbarButton: View {
    @State private var inputText: String = "1234"
    @ObservedObject var holder = TextHolder.shared
    public var body: some View {
        VStack {
            TextFieldRepresentable(placeholder: "Input text", text: $inputText)
            .toolbar {
                ToolbarItem(id: UUID().uuidString, placement: .automatic) {
                    HStack {
                        Button("+") {
                               insertPlus()
                        }
                    }
                }
            }
        }
    }
    
    ///Inserts the plus character at the selectedRange/
    func insertPlus(){
        //First, we will check if our range is not nil
         guard let selectedRange = holder.selectedRange else {
             //Handle errors, as we could not get the selected range
             print("The holder did not contain a selected range")
             return
         }
         let endPos = inputText.index(inputText.startIndex, offsetBy: selectedRange.location) // End of the selected range position
         //Insert the text
         inputText.insert(contentsOf: "+", at: endPos)
        //Necessary to move cursor to correct location
        TextHolder.shared.justChanged = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldStringToolbarButton()
    }
}
