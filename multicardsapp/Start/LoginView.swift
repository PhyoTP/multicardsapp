import SwiftUI

struct LoginView: View{
    @Environment(\.dismiss) var dismiss
    @Environment(UserManager.self) var userManager: UserManager
    @State private var errorOccurred = false
    @State private var errorDesc = ""
    @AppStorage("isDone") var done = false
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("username") var name = "You"
    var body: some View{
        @Bindable var userManager = userManager
        Form{
            Section("Log in"){
                TextField("Username", text: $userManager.user.username)
                SecureField("Password",text: $userManager.user.password)
            }
            .listRowBackground(back)
            Section{
                Button("Log in"){
                    Task {
                        do {
                            try await userManager.login()
                            isLoggedIn = true
                            done = true
                            name = userManager.user.username
                            dismiss()
                        } catch {
                            errorDesc = userManager.error
                            errorOccurred = true
                        }
                        
                    }
                    
                }
                Button("Cancel",role: .destructive){
                    dismiss()
                }
            }
            .alert("An error occurred", isPresented: $errorOccurred){
                
            }message: {
                Text(errorDesc)
            }
            .listRowBackground(back)
        }
        .unifiedBackground()
    }
}

