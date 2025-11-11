import SwiftUI

struct RegisterView: View{
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
            Section("Register"){
                TextField("Username", text: $userManager.user.username)
                SecureField("Password",text: $userManager.user.password)
            }
            .listRowBackground(back)
            Section{
                Button("Register"){
                    Task{
                        do{
                            try await userManager.register()
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
