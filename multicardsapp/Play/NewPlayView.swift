import SwiftUI
protocol Options{ init() }
protocol Sides {
    init(sideDict: [String: [String]])
    var sideDict: [String: [String]] { get set }
    static var sides: [String] { get }
}
extension Sides {

    init() {
        var dict: [String:[String]] = [:]

        for side in Self.sides {
            dict[side] = []
        }

        self.init(sideDict: dict)
    }

    func side(_ s: String) -> [String] {
        sideDict[s] ?? []
    }
}

func bindOption<T: Options>(options: Binding<Options>, as type: T.Type) -> Binding<T> {
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
    var description: String
    var makeView: ([Card], any Options, any Sides) -> AnyView
    var options: any Options.Type
    var sides: any Sides.Type
}

let gamemodes = [
    Gamemode(name: "Flashcards", icon: "rectangle.stack", description: "Simple, basic flashcards", makeView: { cards, options, sides in
        AnyView(FlashcardsView(fullCards: cards, options: options, sides: sides))}, options: FlashcardsOptions.self, sides: FlashcardsSides.self),
    Gamemode(name: "Match", icon: "rectangle.grid.3x2", description: "Match sides together in time", makeView: { cards, options, sides in
        AnyView(MatchView(fullCards: cards, options: options, sides: sides))}, options: MatchOptions.self, sides: MatchSides.self),
    Gamemode(name: "Write", icon: "rectangle.and.pencil.and.ellipsis", description: "Type out the answer", makeView: { cards, options, sides in
        AnyView(WriteView(fullCards: cards, options: options, sides: sides))}, options: WriteOptions.self, sides: WriteSides.self)
]
struct NewPlayView: View{
    var cards: [Card]
    @State private var chosenSides: any Sides = FlashcardsSides()
    @State private var chosenSettings: any Options = FlashcardsOptions()
    @State private var chosenGamemode = 0
    @State private var rotation = 0.0
    var sides: [String]{
        Array(Set(cards.flatMap { $0.sides.keys })).sorted()
    }
    func next(){
        withAnimation {
            rotation = -45
        }completion: {
            rotation = 0
            chosenGamemode += 1
            if chosenGamemode >= gamemodes.count{
                chosenGamemode = 0
            }
            chosenSettings = gamemodes[chosenGamemode].options.init()
            chosenSides = gamemodes[chosenGamemode].sides.init()
        }
    }
    func prev(){
        withAnimation {
            rotation = 45
        }completion: {
            rotation = 0
            chosenGamemode -= 1
            if chosenGamemode < 0{
                chosenGamemode = gamemodes.count - 1
            }
            chosenSettings = gamemodes[chosenGamemode].options.init()
            chosenSides = gamemodes[chosenGamemode].sides.init()
        }
    }
    var body: some View{
        NavigationStack{
            ScrollView(.vertical){
                VStack(alignment: .leading){
                    Text("Choose a game mode").header()
                    HStack{
                        Button {
                            prev()
                        }label:{
                            Image(systemName: "chevron.left")
                                .font(.largeTitle)
                        }
                        Spacer()
                        VStack{
                            ZStack{
                                let before = chosenGamemode - 1 < 0 ? gamemodes.count - 1 : chosenGamemode - 1
                                let beforeb = chosenGamemode - 2 < 0 ? gamemodes.count + chosenGamemode - 2 : chosenGamemode - 2
                                let after = chosenGamemode + 1 >= gamemodes.count ? 0 : chosenGamemode + 1
                                let aftera = chosenGamemode + 2 >= gamemodes.count ? (chosenGamemode + 2) % gamemodes.count : chosenGamemode + 2
                                ModeView(mode: gamemodes[beforeb])
                                    .rotation3DEffect(.degrees(-45+rotation*2), axis: (x: 0, y: -1, z: 0))
                                    .scaleEffect(0.2+rotation/45*0.4)
                                    .offset(x: -135)
                                ModeView(mode: gamemodes[aftera])
                                    .rotation3DEffect(.degrees(45+rotation*2), axis: (x: 0, y: -1, z: 0))
                                    .scaleEffect(0.2-rotation/45*0.4)
                                    .offset(x: 135)
                                ModeView(mode: gamemodes[before])
                                    .rotation3DEffect(.degrees(45-rotation), axis: (x: 0, y: -1, z: 0))
                                    .scaleEffect(0.6+rotation/45*0.4)
                                    .offset(x: -135+abs(rotation)/45*135)
                                    .onTapGesture(perform: prev)
                                ModeView(mode: gamemodes[after])
                                    .rotation3DEffect(.degrees(45+rotation), axis: (x: 0, y: 1, z: 0))
                                    .scaleEffect(0.6-rotation/45*0.4)
                                    .offset(x: 135-abs(rotation)/45*135)
                                    .onTapGesture(perform: next)
                                ModeView(mode: gamemodes[chosenGamemode])
                                    .rotation3DEffect(.degrees(-rotation), axis: (x: 0, y: -1, z: 0))
                                    .scaleEffect(1-abs(rotation)/45*0.4)
                                    .offset(x: rotation/45*135)
                            }
                            Text(gamemodes[chosenGamemode].description)
                            
                        }
                        Spacer()
                        Button{
                            next()
                        }label:{
                            Image(systemName: "chevron.right")
                                .font(.largeTitle)
                        }
                    }
                    .gesture(
                        DragGesture()
                            .onChanged{ value in
                                let translated = value.translation.width / 135 * 45
                                rotation = abs(translated) > 45 ? (Int(translated).signum() == 1 ? 45 : -45) : translated
                            }
                            .onEnded{ value in
                                if value.translation.width > 0{
                                    prev()
                                }else if value.translation.width < 0{
                                    next()
                                }
                            }
                    )
                    Text("Options").header()
                    VStack{
                        if let _ = chosenSettings as? FlashcardsOptions{
                            Toggle("Shuffled?", isOn: bindOption(options: $chosenSettings, as: FlashcardsOptions.self).shuffled)
                        }
                        if let _ = chosenSettings as? MatchOptions{
                            Toggle("Refill?", isOn: bindOption(options: $chosenSettings, as: MatchOptions.self).refill)
                            HStack{
                                Text("Card Amount:")
                                TextField("Amount", value: bindOption(options: $chosenSettings, as: MatchOptions.self).amount, formatter: NumberFormatter())
                                    .padding(5)
                                    .background(.primary.opacity(0.1))
                                    .mask(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        if let _ = chosenSettings as? WriteOptions{
                            Toggle("Case sensitive?", isOn: bindOption(options: $chosenSettings, as: WriteOptions.self).caseSensitive)
                            Toggle("Ignore spaces?", isOn: bindOption(options: $chosenSettings, as: WriteOptions.self).ignoreSpaces)
                            Toggle("Shuffled?", isOn: bindOption(options: $chosenSettings, as: WriteOptions.self).shuffled)
                            Toggle("Corrections?", isOn: bindOption(options: $chosenSettings, as: WriteOptions.self).corrections)
                        }
                    }
                    .item()
                    Text("Sides").header()
                    VStack{
                        HStack(alignment: .top){
                            ForEach(type(of: chosenSides).sides, id: \.self) { side in
                                if let sideArray = chosenSides.sideDict[side]{
                                    ZStack{
                                        Rectangle()
                                            .fill(bg.opacity(0.1))
                                        VStack{
                                            Text(side.capitalized)
                                            ForEach(sideArray, id: \.self) { s in
                                                HStack{
                                                    Text(s)
                                                    Button("", systemImage: "xmark"){
                                                        chosenSides.sideDict[side]!.removeAll(where: {$0 == s})
                                                    }
                                                }
                                                .padding(5)
                                                .background(RoundedRectangle(cornerRadius: 10).fill(accent))
                                                .foregroundStyle(.black)
                                            }
                                        }
                                    }
                                        .padding()
                                        .glassEffect(in: RoundedRectangle(cornerRadius: 25))
                                    
                                        .dropDestination(for: String.self) { items, location in
                                            chosenSides.sideDict[side]!.append(contentsOf: items.filter{!chosenSides.sideDict[side]!.contains($0) && sides.contains($0)})
                                        }
                                }
                            }
                            
                        }
                        HStack{
                            ForEach(sides, id: \.self) { side in
                                Text(side)
                                    .padding(5)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(accent))
                                    .foregroundStyle(.black)
                                    .draggable(side)
                            }
                        }
                    }
                    .item()
                    Text("Drag sides into the boxes")
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                    let view = gamemodes[chosenGamemode].makeView(cards, chosenSettings, chosenSides)
                    NavigationLink(destination: view) {
                        Label("Play", systemImage: "play.fill")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(accent)
                            )
                            .foregroundStyle(back)
                    }
                    
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(bg)
            .navigationTitle("Play")
            
        }
    }
}
#Preview{
    NewPlayView(cards: [Card(sides: ["a":"b","c":"d"])])
        .preferredColorScheme(ColorScheme.dark)
    
}
extension View{
    func item() -> some View {
        self.padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(back)
            )
    }
}
struct ModeView: View{
    var mode: Gamemode
    var body: some View{
        VStack{
            Image(systemName: mode.icon)
            Text(mode.name)
        }
        .frame(width: 150, height: 150)
//        .glassEffect(.regular.tint(back), in: RoundedRectangle(cornerRadius: 25))
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(back)
        )
    }
}
