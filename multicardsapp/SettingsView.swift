import SwiftUI

struct SettingsView: View{
    @State private var showAlert = false
    @Environment(UserManager.self) var userManager: UserManager
    @Environment(LocalSetsManager.self) var localSetsManager: LocalSetsManager
    @State private var login = false
    @State private var register = false
    @Environment(RecentSetManager.self) var recentSetManager: RecentSetManager
    @AppStorage("isDone") var done = false
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("username") var name = "You"
    var body: some View{
        @Bindable var recentSetManager = recentSetManager
        NavigationStack{
            Form{
                Section("PhyoID"){
                    if isLoggedIn{
                        
                        Text("Logged in as "+name)
                        Button("Log out",role: .destructive){
                            showAlert = true
                        }
                        Link("View account",destination: URL(string: "https://auth.phyotp.dev")!)
                    }else{
                        
                        Button("Log in"){
                            login = true
                        }
                        Button("Register"){
                            register = true
                        }
                        
                    }
                }
                .listRowBackground(back)
                Section{
                    Button("Clear recent sets", role: .destructive) {
                        recentSetManager.sets = []
                    }
                }
                .listRowBackground(back)
            }
            .navigationTitle("Settings")
            .unifiedBackground()
        }
        .alert("Are you sure you want to log out?", isPresented: $showAlert){
            Button("Log out",role: .destructive){
                done = false
                isLoggedIn = false
                name = "You"
                deleteToken()
                localSetsManager.localSets = []
                userManager.user = User(username: "", password: "")
                recentSetManager.sets = []
            }
        }
        .sheet(isPresented: $login, content: {
            LoginView()
        })
        .sheet(isPresented: $register, content: {
            RegisterView() 
        })
    }
}
