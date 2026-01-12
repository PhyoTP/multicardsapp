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
                .font(.custom("AvenirNext-bold", size: 40))
                .shiny()
                .multilineTextAlignment(.center)
            IntroView(image: "rectangle.stack", title: "Create multi-dimensional flashcards", description: "Have different sides for different parts, eg. word, pronunciation, meaning")
            Button("Get started") {
                done = true
            }
            .big()
            HStack{
                Button("Log in") {
                    login = true
                }
                Button("Sign up") {
                    register = true
                }
            }
        }
        .sheet(isPresented: $login, content: {
            LoginView()
        })
        .sheet(isPresented: $register, content: {
            RegisterView()
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(50)
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
#Preview {
    StartView()
        .environment(UserManager())
        .preferredColorScheme(ColorScheme.dark)
}
struct IntroView: View {
    var image: String
    var title: String
    var description: String
    var body: some View {
        HStack{
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: 60)
                .padding(10)
                .foregroundStyle(Color.accentColor)
            VStack(alignment: .leading){
                Text(title)
                    .bold()
                Text(description)
            }
        }
    }
}
