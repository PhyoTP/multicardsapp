import SwiftUI

struct ImportView: View{
    @State private var text = ""
    @State private var selectedTermSeparator: String = TermSeparator.tab.rawValue
    @State private var selectedCardSeparator: String = CardSeparator.newline.rawValue
    @Environment(\.dismiss) var dismiss
    @Binding var result: [Column]
    var body: some View{
        Form{
            Section("Set"){
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
            }
            .listRowBackground(back)
            Section{
                TextField("Paste here", text: $text, axis: .vertical)
                Button("Import"){
                    result=convertStringToColumns()
                    dismiss()
                    
                }
                Button("Cancel", role: .destructive){
                    dismiss()
                }
            }
            .listRowBackground(back)
        }
        .unifiedBackground()
    }
    func convertStringToColumns() -> [Column] {
        // Split the string into cards based on the card separator
        let rawCards = text.components(separatedBy: selectedCardSeparator)
        
        var columns: [Column] = []
        var columnCount = 0
        
        for card in rawCards {
            // Split each card into terms based on the term separator
            let components = card.components(separatedBy: selectedTermSeparator).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            
            // Ensure the columns array has enough columns to accommodate all components
            if components.count > columnCount {
                for i in columnCount..<components.count {
                    columns.append(Column(name: "Dimension \(i + 1)", values: []))
                }
                columnCount = components.count
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

