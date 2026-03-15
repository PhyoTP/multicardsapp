import SwiftUI

struct CreateSetView: View {
    @State private var set: CardSet = CardSet(name: "", cards: [], creator: "", isPublic: false, tags: [])
    @Environment(\.dismiss) var dismiss
    @State private var showSheet = false
    @State private var columns: [Column] = [Column(name: "", values: [""]),Column(name: "", values: [""])]
    @State private var showAlert = false
    @State private var alertDesc = ""
    @Environment(LocalSetsManager.self) var localSetsManager: LocalSetsManager
    @Environment(SetsManager.self) var setsManager: SetsManager
    @State private var tagsText = ""
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("username") var name: String = "You"
    var body: some View {
        NavigationStack{
            Form {
                Section("Details") {
                    TextField("Title", text: $set.name)
                    if isLoggedIn {
                        Toggle("Make Public", isOn: $set.isPublic)
                    }
                    HStack{
                        Text("Tags: ")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack{
                                ForEach(Array(set.safeTags), id: \.self){tag in
                                    HStack{
                                        Text(tag)
                                        Button{
                                            set.tags?.remove(tag)
                                        }label:{
                                            Image(systemName: "xmark")
                                        }
                                    }
                                    .padding(5)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(accent))
                                    .foregroundStyle(.black)
                                    
                                }
                            }
                        }
                    }
                    HStack{
                        TextField("Add tag", text: $tagsText)
                        Button("Add"){
                            if set.tags == nil{
                                set.tags = []
                            }
                            set.tags!.insert(tagsText)
                            tagsText = ""
                        }
                        .disabled(tagsText.isEmpty)
                    }
                }
                .listRowBackground(back)
                Section(header:Text("Table"), footer:
                            Button("Import", systemImage: "square.and.arrow.down") {
                    showSheet = true
                }
                ) {
                    GridView(columns: $columns)
                }
                .listRowBackground(back)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .sheet(isPresented: $showSheet) {
                ImportView(result: $columns)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertDesc), dismissButton: .default(Text("OK")))
            }
            .unifiedBackground()
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Create", role: .confirm) {
                        let names = columns.map { $0.name }
                        if set.name.isEmpty {
                            showAlert = true
                            alertDesc = "Title cannot be blank"
                        } else if names.contains("") {
                            showAlert = true
                            alertDesc = "Dimension name cannot be blank"
                        } else if columns.numCards == 0{
                            showAlert = true
                            alertDesc = "Must have at least one card"
                        } else {
                            set.cards = columns.cards
                            set.creator = name
                            localSetsManager.localSets.append(set)
                            dismiss()
                            localSetsManager.sync()
                            if set.isPublic{
                                setsManager.postSet(set)
                            }
                            setsManager.getSets()
                            
                        }
                    }
                }
            }
        }
    }
}

#Preview{
    CreateSetView()
        .environment(LocalSetsManager())
        .environment(SetsManager())
        .preferredColorScheme(.dark)
}
