import SwiftUI
struct ContentView: View {
    @Environment(UserManager.self) var userManager: UserManager
    @Environment(SetsManager.self) var setsManager: SetsManager
    @Environment(RecentSetManager.self) var recentSetManager: RecentSetManager
    @Environment(LocalSetsManager.self) var localSetsManager: LocalSetsManager
    @State private var selection = "home"
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.largeTitleTextAttributes = [
            .font : UIFont(name: "AvenirNext-bold", size: 34)!
        ]
        appearance.titleTextAttributes = [
            .font : UIFont(name: "AvenirNext-bold", size: 18)!
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    @AppStorage("isDone") var done = false
    @State private var searchText: String = ""
    var filteredSets: [SetCover]{
        var allSets = localSetsManager.setCovers
        if let sets = setsManager.sets{
            allSets += sets
        }
        if searchText.isEmpty{
            return Array(Set(allSets).subtracting(Set(recentSetManager.sets)))
        }else{
            return allSets.filter{$0.name.lowercased().contains(searchText.lowercased())}
        }
    }
    var body: some View {
        VStack(spacing: 0){
            if done {
                TabView(selection: $selection) {
                    Tab(value: "library"){
                        LibraryView()
                    }label: {
                        Label("Library", systemImage: "books.vertical")
                    }
                    Tab(value: "home"){
                        NewHomeView()
                    }label: {
                        Label("Home", systemImage: "house")
                    }
                    Tab(value: "settings") {
                        SettingsView()
                    }label: {
                        Label("Settings", systemImage: "gear")
                    }
                    Tab(value: "search", role: .search) {
                        
                        NavigationStack{
                            if searchText.isEmpty{
                                VStack{
                                    Image(systemName: "rectangle.and.pencil.and.ellipsis")
                                        .font(.system(size: 60))
                                    Text("Search for study sets...")
                                }
                                .foregroundStyle(.gray)
                                .padding()
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(bg)
                            }else if filteredSets.isEmpty{
                                VStack{
                                    Image(systemName: "questionmark.text.page")
                                        .font(.system(size: 60))
                                    Text("No results found, are you sure you're searching for the right thing?")
                                }
                                .foregroundStyle(.gray)
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
                        
                        .searchable(text: $searchText)
                    }
                }
                .onAppear(){
                    userManager.relogin()
                    selection = "home"
                }
                .tabViewSearchActivation(.searchTabSelection)
            } else {
                Spacer()
                StartView()
                Spacer()
            }
        }
        .ignoresSafeArea()
        .safeAreaInset(edge: .top){
            CheckOfflineView()
        }
        
    }
}
struct CheckOfflineView: View{
    @Environment(SetsManager.self) var setsManager: SetsManager
    @State private var gone = false
    var body: some View{
        if !gone{
            if setsManager.errorDesc == "a"{
                HStack{
                    Link(destination: URL(string: "https://stats.uptimerobot.com/rX1n6yYoIp/799271942")!){
                        Image(systemName: "cellularbars")
                            .padding()
                    }
                    Spacer()
                    Text("Checking connection...")
                        .fontWeight(.medium)
                        .padding()
                        .multilineTextAlignment(.center)
                    Spacer()
                    Button{
                        gone = true
                    }label: {
                        Image(systemName: "xmark")
                            .padding()
                    }
                }
                .background(accent)
                .foregroundStyle(.black)
                .onAppear(){
                    setsManager.getSets()
                }
            }else if setsManager.errorDesc == "No error"{
                EmptyView()
            }else{
                HStack{
                    Menu{
                        Button{
                            setsManager.getSets()
                        }label: {
                            Label("Retry", systemImage: "arrow.counterclockwise")
                        }
                        Link(destination: URL(string: "https://stats.uptimerobot.com/rX1n6yYoIp/799271942")!){
                            Label("Check uptime", systemImage: "cellularbars")
                        }
                    }label: {
                        Image(systemName: "ellipsis.circle")
                            .padding()
                    }
                    
                    Spacer()
                    Text(setsManager.errorDesc)
                        .fontWeight(.medium)
                        .padding()
                        .multilineTextAlignment(.center)
                    Spacer()
                    
                    
                    Button{
                        gone = true
                    }label: {
                        Image(systemName: "xmark")
                            .padding()
                    }
                    
                }
                .background(.red)
                .foregroundStyle(.white)
                
            }
            
        }
    }
}
#Preview{
    ContentView()
        .environment(UserManager())
        .environment(LocalSetsManager())
        .environment(SetsManager())
        .environment(RecentSetManager())
        .preferredColorScheme(.dark)
}
