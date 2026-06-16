import SwiftUI

struct ImportView: View{
    @State private var text = ""
    @State private var selectedTermSeparator: String = TermSeparator.tab.rawValue
    @State private var selectedCardSeparator: String = CardSeparator.newline.rawValue
    @Environment(\.dismiss) var dismiss
    @Binding var result: [Column]
    @State private var hasHeader = false
    @State private var convertError: ConvertError?
    var body: some View{
        NavigationStack{
            Form{
                Section("Options"){
                    HStack{
                        Text("Term Separator:")
                        Picker("Term Separator", selection: $selectedTermSeparator) {
                            ForEach(TermSeparator.allCases, id: \.self) { separator in
                                Text(separator.label).tag(separator.rawValue)
                            }
                            Text("Custom").tag(TermSeparator.allCases.contains(where: { $0.rawValue == selectedTermSeparator }) ? "" : selectedTermSeparator)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    if selectedTermSeparator.isEmpty || !TermSeparator.allCases.contains(where: { $0.rawValue == selectedTermSeparator }) {
                        TextField("Term Separator", text: $selectedTermSeparator)
                    }
                    HStack{
                        Text("Card Separator:")
                        // Picker for card separator
                        Picker("Card Separator", selection: $selectedCardSeparator) {
                            ForEach(CardSeparator.allCases, id: \.self) { separator in
                                Text(separator.label).tag(separator.rawValue)
                            }
                            Text("Custom").tag(CardSeparator.allCases.contains(where: { $0.rawValue == selectedCardSeparator }) ? "" : selectedCardSeparator)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    if selectedCardSeparator.isEmpty || !CardSeparator.allCases.contains(where: { $0.rawValue == selectedCardSeparator }) {
                        TextField("Card Separator", text: $selectedCardSeparator)
                    }
                    Toggle("Has headers?", isOn: $hasHeader)
                }
                .listRowBackground(back)
                Section{
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $text)
                            .padding(4)
                        
                        if text.isEmpty {
                            Text("\(hasHeader ? "Header a \(selectedTermSeparator) Header b \(selectedCardSeparator)":"")Term 1a \(selectedTermSeparator) Term 1b \(selectedCardSeparator)Term 2a \(selectedTermSeparator) Term 2b")
                                .foregroundColor(Color(.placeholderText))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 12)
                                .allowsHitTesting(false)
                        }
                    }
                }
                .listRowBackground(back)
            }
            .unifiedBackground()
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Import",role: .confirm){
                        do{
                            result=try convertStringToColumns()
                            dismiss()
                        }catch let e as ConvertError{
                            convertError = e
                        }catch{
                            print(error.localizedDescription)
                        }
                    }
                    .disabled(selectedCardSeparator.isEmpty || selectedTermSeparator.isEmpty || text.isEmpty)
                }
            }
            .alert(isPresented: Binding(
                    get: { convertError != nil },
                    set: { newValue in
                        if !newValue {
                            convertError = nil // Dismiss the alert and clear the error
                        }
                    }
                ), error: convertError) {
                    // Actions (buttons)
                    Button("OK") {
                    }
                }
        }
    }
    func convertStringToColumns() throws -> [Column] {
        // Split the string into cards based on the card separator
        var rawCards = text.components(separatedBy: selectedCardSeparator)
        var headers: [String] = []
        if hasHeader{
            headers = rawCards.removeFirst().components(separatedBy: selectedTermSeparator).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        }
        
        var columnCount = headers.count
        if columnCount == 0{
            guard let c = rawCards.first?.components(separatedBy: selectedTermSeparator).map ({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }).count else {
                throw ConvertError.noCards
            }
            columnCount = c
        }
        var columns: [Column] = []
        
        for i in 0..<columnCount {
            columns.append(Column(name: headers.isEmpty ? "Dimension \(i + 1)": headers[i], values: []))
        }
        for card in rawCards {
            // Split each card into terms based on the term separator
            let components = card.components(separatedBy: selectedTermSeparator).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            
            // Ensure the columns array has enough columns to accommodate all components
            if components.count != columnCount {
                throw ConvertError.unequalColumns
            }
            
            // Append each component to the corresponding column
            for i in components.indices {
                columns[i].values.append(components[i])
            }
        }
        
        return columns
    }
    
}
enum TermSeparator: String, CaseIterable {
    case tab = "\t"
    case comma = ","
    var label: String {
        switch self {
        case .tab: return "Tab"
        case .comma: return "Comma"
        }
    }
}

enum CardSeparator: String, CaseIterable {
    case newline = "\n"
    case semicolon = ";"
    var label: String {
        switch self {
        case .newline: return "Newline"
        case .semicolon: return "Semicolon"
        }
    }
}

enum ConvertError: LocalizedError{
    case noCards
    case unequalColumns
    var errorDescription: String? {
        switch self {
        case .noCards: return "No cards found."
        case .unequalColumns: return "Cards have an unequal number of columns."
        }
    }
}
