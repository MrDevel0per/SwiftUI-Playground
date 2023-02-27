# Question Info
- **Name**: SwiftUI, change the TextField string from the toolbar button
- **Link**: https://stackoverflow.com/questions/75571977/swiftui-change-the-textfield-string-from-the-toolbar-button

# Question Body
> In SwiftUI, how can I insert a string at the current cursor position of the TextField?
In below example, I want to change the string from `1234` to `12+34` in the toolbar button event.
> 
> ```swift
> @State private var inputText: String = "1234"
> 
> public var body: some View {
>     VStack {
>        TextField("Input text", text: $inputText)
>        .toolbar {
>            ToolbarItemGroup(placement: .keyboard) {
>                HStack {
>                    Button("+") {
>                        //
>                        // Here I want to insert "+" at the current cursor position.
>                        //
>                    }
>                }
>            }
>        }
>    }
>}
>```