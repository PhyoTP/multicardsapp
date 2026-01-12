import SwiftUI
let accent: Color = Color(red: 228/255, green: 148/255, blue: 27/255)
let bg: Color = Color(red: 0.231373, green: 0.141176, blue: 0)
let back: Color = Color(red: 0.36078, green: 0.21569, blue: 0.039216)
@main
struct MyApp: App {
    @AppStorage("isDone") var done: Bool = false
    @State private var openSet: Bool = false
    @State private var id = UUID()
    @State var setsManager = SetsManager()
    @State var localSetsManager = LocalSetsManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(UserManager())
                .environment(localSetsManager)
                .environment(setsManager)
                .environment(RecentSetManager())
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    if done{
                        print("Opened from: \(url.absoluteString)")
                        if url.host == "api.phyotp.dev" || url.host == nil{
                            let pathComponents = url.pathComponents
                            print(pathComponents)
                            if pathComponents.count >= 5 && pathComponents[3] == "set"{
                                id = UUID(uuidString: pathComponents[4]) ?? id
                                setsManager.getSets()
                                openSet = true
                            }
                        }
                    }
                }
                .sheet(isPresented: $openSet) {
                    if let localSet = $localSetsManager.localSets.first(where: {$0.id == id}){
                        LocalSetView(set: localSet)
                    }else{
                        SetView(setID: id)
                    }
                }
        }
    }
}
