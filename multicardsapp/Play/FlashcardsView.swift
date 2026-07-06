import SwiftUI
struct FlashcardsOptions: Options{
    init() {}
    var shuffled = true
    var infinite = true
}
struct FlashcardsSides: Sides {
    var sideDict: [String: [String]]
    static let sides = ["questions", "answers"]
}
struct FlashcardsView: View {
    init(fullCards: [Card], options: any Options, sides: any Sides) {
        self.fullCards = fullCards
        self.sides = sides as? FlashcardsSides ?? FlashcardsSides()
        self.options = options as? FlashcardsOptions ?? FlashcardsOptions()
    }
    
    var fullCards: [Card]
    @State private var cards: [Card] = []
    @State private var tapped = false
    @State private var rotation = 0.0
    @State private var know: [Card] = []
    @State private var dontKnow: [Card] = []
    @State private var last: [Bool] = []
    @State private var count = 0
    var options: FlashcardsOptions
    var sides: FlashcardsSides
    var body: some View {
        GeometryReader{geometry in
            
            if Set(cards).isSubset(of: Set(know + dontKnow)){
                HStack{
                    Spacer()
                    VStack{
                        Spacer()
                        DonutChartView(total: Double(fullCards.count), know: Double(count))
                        Spacer()
                        Button("Try again"){
                            know = []
                            dontKnow = []
                            cards = fullCards
                            if options.shuffled{
                                cards.shuffle()
                            }
                            last = []
                            count = 0
                        }
                        .big()
                        if !dontKnow.isEmpty{
                            Button("Try again with unknown"){
                                cards = dontKnow
                                if options.shuffled{
                                    cards.shuffle()
                                }
                                know = []
                                dontKnow = []
                                last = []
                            }
                            .big()
                        }
                        Spacer()
                        
                            .onAppear(){
                                count += know.count
                            }
                    }
                    Spacer()
                }
                .frame(maxHeight: .infinity)
                .background(bg)
            }else{
                NavigationStack{
                    VStack{
                        Spacer()
                        HStack{
                            Spacer()
                            Image(systemName: "arrow.left")
                            if !options.infinite{
                                Text(String(know.count))
                            }
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.system(size: 30))
                            Spacer()
                            Image(systemName: "multiply.circle.fill")
                                .foregroundStyle(.red)
                                .font(.system(size: 30))
                            if !options.infinite{
                                Text(String(dontKnow.count))
                            }
                            Image(systemName: "arrow.right")
                            Spacer()
                        }
                        .navigationTitle(Text(options.infinite ? "Infinite" : String(cards.count-know.count-dontKnow.count)+" left"))
                        ZStack {
                            ForEach($cards.reversed()) { $card in
                                VStack{
                                    if tapped{
                                        ForEach(sides.side("answers"), id: \.self){ans in
                                            VStack{
                                                Text(ans)
                                                    .fontWeight(.medium)
                                                    .scaleEffect(x: -1, y: 1)
                                                    .minimumScaleFactor(0.2)
                                                    .multilineTextAlignment(.center)
                                                    .foregroundStyle(accent)
                                                Text(card.sides[ans] ?? "")
                                                    .scaleEffect(x: -1, y: 1)
                                                    .minimumScaleFactor(0.2)
                                                    .multilineTextAlignment(.center)
                                            }
                                            .padding()
                                            if sides.side("answers").last != ans{
                                                Divider()
                                            }
                                        }
                                        
                                    }else{
                                        ForEach(sides.side("questions"), id: \.self){que in
                                            VStack{
                                                Text(que)
                                                    .fontWeight(.medium)
                                                    .minimumScaleFactor(0.2)
                                                    .multilineTextAlignment(.center)
                                                    .foregroundStyle(accent)
                                                Text(card.sides[que] ?? "")
                                                    .minimumScaleFactor(0.2)
                                                    .multilineTextAlignment(.center)
                                            }
                                            .padding()
                                            if sides.side("questions").last != que{
                                                Divider()
                                            }
                                        }
                                    }
                                }
                                .frame(width: 200, height: 400)
                                .background(back)
                                .mask{
                                    RoundedRectangle(cornerRadius: 20)
                                }
                                .gesture(
                                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                    
                                        .onEnded({value in
                                            
                                            withAnimation(){
                                                if (value.translation.width > 0) != tapped{
                                                    if options.infinite{
                                                        card.streak = max(1, Int(card.streak/2))
                                                    }
                                                    dontKnow.append(card)
                                                    last.append(false)
                                                }else{
                                                    if options.infinite{
                                                        card.streak += 1
                                                    }
                                                    know.append(card)
                                                    last.append(true)
                                                }
                                                
                                            }completion: {
                                                if options.infinite{
                                                    let interval = card.streak * 2 - 1
                                                    let c = cards.remove(at: 0)
                                                    cards.insert(c, at: min(interval, cards.count))
                                                    withAnimation{
                                                        if dontKnow.count > 0{
                                                            dontKnow = []
                                                        }else{
                                                            know = []
                                                        }
                                                    }
                                                }
                                            }
                                                tapped = false
                                                rotation = 0
                                            
                                        })
                                )
                                .highPriorityGesture(
                                    TapGesture()
                                        .onEnded{
                                            withAnimation(){
                                                rotation += 180
                                            }
                                            tapped.toggle()
                                        }
                                )
                                .rotation3DEffect(
                                    Angle(degrees: rotation), axis: (x: 0.0, y: 1.0, z: 0.0)
                                )
                                .offset(x:
                                        know.contains(where: {$0.id==card.id}) ?
                                            -geometry.size.width
                                        :
                                            dontKnow.contains(where: {$0.id==card.id}) ?
                                                geometry.size.width
                                            :
                                                0
                                        
                                )
                                
                            }
                        }
                        if !last.isEmpty && !options.infinite /* to implement */{
                            Button("Undo", systemImage: "arrow.counterclockwise") {
                                withAnimation {
                                    if last.last == true && !know.isEmpty {
                                        know.remove(at: know.count - 1)
                                        last.remove(at: last.count-1)
                                    }else if last.last == false && !dontKnow.isEmpty {
                                        dontKnow.remove(at: dontKnow.count - 1)
                                        last.remove(at: last.count-1)
                                    }
                                    print(last)
                                }
                            }
                        }
                        Spacer()
                    }
                    .background(bg)
                }
            }
        }
        .onAppear(){
            cards = fullCards
            if options.shuffled{
                cards.shuffle()
            }
        }
    }
}

#Preview {
    FlashcardsView(fullCards: [Card(sides: ["a":"1","c":"2"]),Card(sides: ["a":"3","c":"4"]),Card(sides: ["a":"5","c":"6"]),Card(sides: ["a":"7","c":"8"]),Card(sides: ["a":"9","c":"10"]),Card(sides: ["a":"11","c":"12"]),Card(sides: ["a":"13","c":"14"]),Card(sides: ["a":"15","c":"16"])], options: FlashcardsOptions(), sides: FlashcardsSides(sideDict: ["questions": ["a"], "answers": ["c"]]))
        .preferredColorScheme(.dark)
}
