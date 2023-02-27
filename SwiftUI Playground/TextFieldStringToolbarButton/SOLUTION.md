# Solution Link: https://stackoverflow.com/questions/75571977/swiftui-change-the-textfield-string-from-the-toolbar-button/75585898#75585898

# Solution Body:

You already have access to the `inputText`, so this is a matter of determining the current cursor position. As seen in [this StackOverflow post](https://stackoverflow.com/a/70954360/20384561), this is currently not possible with pure SwiftUI. However, using a custom implimentation, you can potentially achieve what you are trying to achieve, via [`String.Index`](https://developer.apple.com/documentation/swift/string/index) and [`NSTextRange`](https://developer.apple.com/documentation/uikit/nstextrange). However, I'm not currently aware of a way to pass this value between SwiftUI and AppKit directy, so my implimentation below uses an [`ObservableObject` singleton](https://developer.apple.com/forums/thread/704622):
## TextHolder
```swift
class TextHolder: ObservableObject{
    ///The shared instance of `TextHolder` for access across the frameworks.
    public static let shared = TextHolder()
    
    ///The currently user selected text range.
    @Published var selectedRange: NSRange? = nil
    
    //NOTE: You can comment the next variable out if you do not need to update cursor location
    ///Whether or not SwiftUI just changed the text
    @Published var justChanged = false
}
```
### Some Explainations:
- `TextHolder.shared` is the singleton here, so that we can access it through SwiftUI and AppKit.
- `selectedRange` is the actual [`NSRange`](https://developer.apple.com/documentation/foundation/nsrange) of the user selected text. We will use the [`location`](https://developer.apple.com/documentation/foundation/nsrange/1459533-location) attribute to add text, as this is where the user's cursor is.
- `justChanged` is a property that reflects whether or not the plus button was just clicked, as we need to move the user's cursor forward one spot (to in front of the plus) if so.
---
## TextFieldRepresentable
```swift
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
        
        return textField
    }
    
    func updateNSView(_ nsView: NSTextField, context: Context) {
        //Update the actual TextField
        nsView.stringValue = text
        //NOTE: You can comment this out if you do not need to update the cursor location
        DispatchQueue.main.async {
            //Move the cursor forward one if SwiftUI just changed the value
            if TextHolder.shared.justChanged{
                nsView.currentEditor()?.selectedRange.location += 1
                TextHolder.shared.justChanged = false
            }
        }
        //END commentable area
        
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
```
---
## And finally, the example `View` usage:
```swift
struct ContentView: View {
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
```
---
Here is an example of this in action:
[![Example Usage][1]][1]
This code has been tested with Xcode 14.2/macOS 13.1.
## Sources
- https://stackoverflow.com/questions/53809128/nstextfield-cursor-position


  [1]: https://i.stack.imgur.com/AbZpf.gif
