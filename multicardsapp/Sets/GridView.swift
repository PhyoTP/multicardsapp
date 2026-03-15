import SwiftUI

struct GridView: View {
    @Binding var columns: [Column]
    @State private var showTranslateSheet = false
    @State private var selectedIndex: Int?
    var body: some View {
        ScrollView(.horizontal){
            Grid {
                // Column Headers
                GridRow {
                    ForEach($columns) { $column in
                        TextField("Side", text: $column.name)
                            .fontWeight(.medium)
                        Menu{
                            if columns.count > 2 {
                                Button("Delete") {
                                    if let index = columns.firstIndex(where: { $0.id == column.id }) {
                                        columns.remove(at: index)
                                    }
                                }
                            }
                            Button("Translate") {
                                if let index = columns.firstIndex(where: { $0.id == column.id }) {
                                    selectedIndex = index
                                    print(columns[index])
                                }else{
                                    print("huh")
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                        HStack{Divider()}
                    }
                    Button {
                        let numCards = columns.map { $0.values.count }.max() ?? 0
                        let newColumn = Column(name: "", values: Array(repeating: "", count: numCards))
                        columns.append(newColumn)
                    }label: {
                        Image(systemName: "plus")
                    }
                }
                
                Rectangle()
                    .fill(Color(.systemGray3))
                    .frame(height: 3)
                // Card rows
                ForEach(0..<columns.numCards, id: \.self) { index in
                    if index > 0{
                        Divider()
                    }
                    GridRow {
                        
                        ForEach($columns) { $column in
                            TextField("Value", text: $column.values[index])
                            Image(systemName: "ellipsis.circle")
                                .opacity(0)
                            HStack{Divider()}
                        }
                        Button{
                            for i in columns.indices{
                                columns[i].values.remove(at: index)
                            }
                        }label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }
                HStack{
                    Button("Add card", systemImage: "plus") {
                        for i in columns.indices {
                            columns[i].values.append("")
                        }
                    }
                    Spacer()
                }
            }
            .padding()
        }
        .sheet(isPresented: $showTranslateSheet, onDismiss: {selectedIndex = nil}){
            if let slindex = selectedIndex{
                TranslateView(columns: columns, targetColumn: $columns[slindex])
            }
        }
        .onChange(of: selectedIndex){
            if selectedIndex != nil{
                showTranslateSheet = true
            }
        }
    }
}
