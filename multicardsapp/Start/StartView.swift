import SwiftUI
import Shiny

struct StartView: View {
    @State private var login = false
    @State private var register = false
    @Environment(UserManager.self) var userManager: UserManager
    @AppStorage("isDone") var done = false
    var body: some View {
        VStack {
            Text("Welcome to Multicards")
                .font(.custom("AvenirNext-bold", size: 34))
                .shiny()
            Button("Log in to PhyoID") {
                login = true
            }
            .big()
            Button("Register for a PhyoID") {
                register = true
            }
            .big()
            Button("Join as a Guest") {
                done = true
            }
            .big()
        }
        .sheet(isPresented: $login, content: {
            LoginView()
        })
        .sheet(isPresented: $register, content: {
            RegisterView()
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(bg)
        .ignoresSafeArea()
    }
}
extension Button{
    func big()-> some View{
        self.frame(width: 200)
            .padding()
            .background(accent)
            .foregroundStyle(.black)
            .cornerRadius(25)
    }
}
