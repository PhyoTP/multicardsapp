import SwiftUI
protocol Options{ init() }
func bindOption<T: Options>(options: Binding<Options?>, as type: T.Type) -> Binding<T> {
    return Binding<T>(
        get: {
            (options.wrappedValue as? T) ?? T.init()
        },
        set: { newValue in
            options.wrappedValue = newValue
        }
    )
}
struct Gamemode{
    var name: String
    var icon: String
    var view: any View.Type
    var options: any Options.Type
}
let gamemodes = [
    Gamemode(name: "Flashcards", icon: "rectangle.stack", view: FlashcardsView.self, options: Flashcards.self),
    Gamemode(name: "Match", icon: "rectangle.grid.3x2", view: MatchView.self, options: Match.self)
]
struct NewPlayView: View{
    @State private var gamemode = ""
    var cards: [Card]
    @State private var chosenSides: [String:String] = [:]
    @State private var chosenSettings: any Options = Flashcards()
    @State private var chosenGamemode = 0
    var body: some View{
        NavigationStack{
            VStack{
                Text("Choose a game mode").header()
                HStack{
                    Button("", systemImage: "chevron.left") {
                        chosenGamemode -= 1
                        if chosenGamemode < 0{
                            chosenGamemode = gamemodes.count - 1
                        }
                        chosenSettings = gamemodes[chosenGamemode].options.init()
                    }
                    .font(.largeTitle)
                    Spacer()
                    VStack{
                        Image(systemName: gamemodes[chosenGamemode].icon)
                        Text(gamemodes[chosenGamemode].name)
                    }
                    .frame(width: 150, height: 150)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(back)
                    )
                    Spacer()
                    Button("", systemImage: "chevron.right") {
                        chosenGamemode += 1
                        if chosenGamemode >= gamemodes.count{
                            chosenGamemode = 0
                        }
                        chosenSettings = gamemodes[chosenGamemode].options.init()
                    }
                    .font(.largeTitle)
                }
                VStack{
                    if chosenSettings is Flashcards{
                        
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(back)
                )
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(bg)
            
                
        }
    }
}
#Preview{
    NewPlayView(cards: [])
        .preferredColorScheme(ColorScheme.dark)
    
}
