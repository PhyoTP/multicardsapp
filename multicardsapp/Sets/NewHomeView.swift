import SwiftUI

struct NewHomeView: View{
    @Environment(SetsManager.self) var setsManager: SetsManager
    @Environment(LocalSetsManager.self) var localSetsManager: LocalSetsManager
    @State private var input = ""
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    var filteredSets: [SetCover]{
        if let sets = setsManager.sets{
            if input.isEmpty{
                return Array(Set(sets).subtracting(Set(recentSetManager.sets)))
            }else{
                return sets.filter{$0.name.lowercased().contains(input.lowercased())}
            }
        }else{
            return []
        }
    }
    var recommendedSets: [SetCover]{
        let tags = Set(localSetsManager.localSets.flatMap { $0.tags ?? [] })
        return filteredSets.filter{
            !Set($0.tags).intersection(tags).isEmpty
        }
    }
    @Environment(RecentSetManager.self) var recentSetManager
    @State private var showCreateSheet = false
    @AppStorage("username") var name: String = "You"
    var body: some View{
        NavigationStack{
            if input.isEmpty{
                ScrollView(.vertical){
                    VStack(alignment: .leading){
                        
                        Text("Quick actions").header()
                        ScrollView(.horizontal){
                            HStack{
                                ActionButton(name: "Create a set", image: "plus"){
                                    showCreateSheet = true
                                }
                                .sheet(isPresented:$showCreateSheet){
                                    CreateSetView()
                                }
                            }
                        }
                        Text("Recent sets").header()
                        ScrollView(.horizontal){
                            HStack{
                                ForEach(recentSetManager.sets.reversed()) { recentSet in
                                    SetCoverView(set: recentSet)
                                }
                            }
                        }
                        if !recommendedSets.isEmpty{
                            Text("For you").header()
                            ScrollView(.horizontal){
                                HStack{
                                    ForEach(recommendedSets) { recommendedSet in
                                        SetCoverView(set: recommendedSet)
                                    }
                                }
                                .onAppear(){
                                    print("reload")
                                    recentSetManager.reload( localSetsManager: localSetsManager, setsManager: setsManager)
                                }
                            }
                        }else{
                            Text("Discover").header()
                            ScrollView(.horizontal){
                                if setsManager.sets == nil{
                                    ProgressView()
                                }else{
                                    HStack{
                                        ForEach(filteredSets) { filteredSet in
                                            SetCoverView(set: filteredSet)
                                        }
                                    }
                                    .onAppear(){
                                        print("reload")
                                        recentSetManager.reload(localSetsManager: localSetsManager, setsManager: setsManager)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    
                }
                .navigationTitle(isLoggedIn ? "Hello, " + name : "Multicards")
                .background(bg)
            }else{
                if filteredSets.isEmpty{
                    VStack{
                        Image(systemName: "questionmark.text.page")
                            .font(.system(size: 60))
                        Text("No results found, are you sure you're searching for the right thing?")
                    }
                    .padding()
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(bg)
                }else{
                    List{
                        Section{
                            ForEach(filteredSets) { filteredSet in
                                RedirectSetView(set: filteredSet)
                            }
                        }
                        .listRowBackground(back)
                    }
                    .unifiedBackground()
                }
            }
        }
        .refreshable{
            setsManager.sets = []
            setsManager.getSets()
        }
    }
}

struct ActionButton: View{
    var name: String
    var image: String
    var action: () -> Void
    var body: some View{
        Button(action: action){
                VStack{
                    Image(systemName: image)
                        .font(.system(size: 30))
                    Text(name)
                        .multilineTextAlignment(.center)
                    
                }
                
                .padding()
                .frame(width: 150, height: 150)
                .glassEffect(.clear.interactive(), in: RoundedRectangle(cornerRadius: 25))
        }
    }
}
extension Text{
    func header() -> some View{
        self
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.leading)
    }
}
struct SetCoverView: View{
    var set: SetCover
    @Environment(SetsManager.self) var setsManager: SetsManager
    @Environment(LocalSetsManager.self) var localSetsManager: LocalSetsManager
    @Environment(RecentSetManager.self) var recentSetManager
    @AppStorage("username") var name: String = "You"
    var body: some View{
        @Bindable var recentSetManager = recentSetManager
        @Bindable var localSetsManager = localSetsManager
        NavigationLink(destination: {
            if set.creator == name {
                if let localSetIndex = localSetsManager.localSets.firstIndex(where: { $0.id == set.id }) {
                    LocalSetView(set: $localSetsManager.localSets[localSetIndex])
                        .onAppear(){
                            if recentSetManager.sets.contains(where: {$0.id==set.id}){
                                recentSetManager.sets.removeAll(where: {$0.id==set.id})
                            }
                            recentSetManager.sets.append(set)
                            print(recentSetManager.sets.map{$0.name})
                        }
                } else {
                    ZStack{
                        bg
                        Text("Set not found locally")
                            .onAppear(){
                                Task{
                                    try await localSetsManager.localSets.append(setsManager.getSet(set.id))
                                }
                                localSetsManager.sync()
                            }
                    }
                }
            } else {
                SetView(setID: set.id)
                    .onAppear(){
                        if recentSetManager.sets.contains(where: {$0.id==set.id}){
                            recentSetManager.sets.removeAll(where: {$0.id==set.id})
                        }
                        recentSetManager.sets.append(set)
                        print(recentSetManager.sets.map{$0.name})
                    }
            }
        }){
            VStack(alignment: .leading){
                Text(set.name)
                    .font(.custom("AvenirNext-bold", size: 18))
                    .multilineTextAlignment(.leading)
                HStack{
                    Text("By "+set.formattedCreator)
                    Spacer()
                    Text(String(set.cardCount))
                    Image(systemName: "rectangle.stack")
                }
                if !set.tags.isEmpty{
                    HStack{
                            Text(set.tags.first!)
                                .padding(5)
                                .glassEffect()
                            if set.tags.count>1{
                                Text("+"+String(set.tags.count-1))
                                    .padding(5)
                                    .glassEffect()
                            }
                    }
                }
            }
            .padding()
            .frame(width: 250, height: 150)
            .background(.quaternary)
            .mask{
                RoundedRectangle(cornerRadius: 25)
            }
        }
    }
}
