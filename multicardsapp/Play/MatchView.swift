import SwiftUI
struct MatchOptions: Options{
    init() {}
    var refill = true
    var amount = 4
}
struct MatchSides: Sides{
    var sideDict: [String: [String]]
    static let sides = ["sides"]
}
struct MatchView: View {
    init(fullCards: [Card], options: any Options, sides: any Sides) {
        self.fullCards = fullCards
        self.s = sides as? MatchSides ?? MatchSides()
        self.options = options as? MatchOptions ?? MatchOptions()
    }
    var fullCards: [Card]
    @State private var cards: [Card] = []
    @State private var selectedSides: [String: String] = [:]
    @State private var startTime = Date()
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var best: TimeInterval = 0
    @State private var done = false
    var options: MatchOptions
    var s: MatchSides
    var sides: [String]{
        s.side("sides")
    }
    @State private var wrongSides: [String: String] = [:]
    @State private var shuffledCards: [String: [Card]] = [:]
    @State private var shuffledFullCards: [Card] = []
    @State private var count = 0
    var body: some View {
        if done{
            VStack{
                Spacer()
                DonutChartView(total: elapsedTime, know: best, decimal: true)
                Spacer()
                Button("Try again"){
                    selectedSides = [:]
                    start()
                }
                .big()
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(bg)
        }else if shuffledCards.isEmpty{
            Rectangle()
                .background(bg)
                .onAppear{
                    start()
                }
        }else{
            NavigationStack{
                ZStack{
                    bg
                        .ignoresSafeArea()
                    Grid {
                        GridRow{
                            ForEach(sides, id: \.self){side in
                                Text(side)
                                    .fontWeight(.bold)
                                    .minimumScaleFactor(0.1)
                                    .padding()
                            }
                        }
                        ForEach(cards.indices) { index in
                            GridRow {
                                ForEach(sides, id: \.self) { side in
                                    let card = shuffledCards[side]?[index] ?? Card(sides: [:])
                                    var color: Color{
                                        if !cards.contains(card){
                                            return .green
                                        }
                                        if wrongSides[side] == card.sides[side]{
                                            return .red
                                        }
                                        if selectedSides[side] == card.sides[side]{
                                            return accent.opacity(0.4)
                                        }
                                        return back
                                    }
                                    Button{
                                        if selectedSides[side] == card.sides[side]{
                                            selectedSides[side] = nil
                                        }else{
                                            selectedSides[side] = card.sides[side]
                                            if selectedSides.count == sides.count{
                                                print("hi")
                                                if let correctIndex = cards.firstIndex(where: {c in
                                                    selectedSides.allSatisfy { key, value in
                                                        c.sides[key] == value
                                                    }
                                                }){
                                                    print("correct")
                                                    var correctCard = Card(sides: [:])
                                                    withAnimation {
                                                        correctCard = cards.remove(at: correctIndex)
                                                    }
                                                    
                                                    if options.refill && count < fullCards.count{
                                                        cards.append(shuffledFullCards[count])
                                                        withAnimation(.linear.delay(0.5)){
                                                            for (s,c) in shuffledCards{
                                                                shuffledCards[s] = c.map{$0 == correctCard ? shuffledFullCards[count] : $0}
                                                            }
                                                            count += 1
                                                        }
                                                    }
                                                    selectedSides = [:]
                                                    if cards.isEmpty{
                                                        timer?.invalidate()
                                                        timer = nil
                                                        if best == 0 || elapsedTime<best{
                                                            best = elapsedTime
                                                        }
                                                        done = true
                                                    }
                                                }else{
                                                    wrongSides = selectedSides
                                                    print(wrongSides)
                                                    withAnimation {
                                                        wrongSides = [:]
                                                    }
                                                }
                                            }
                                        }
                                    }label:{
                                            Text(card.sides[side] ?? "")
                                                .minimumScaleFactor(0.1)
                                        .padding()
                                        .frame(idealWidth: 100, maxWidth: .infinity, idealHeight: 140, maxHeight: .infinity)
                                        .background(color)
                                        .mask{
                                            RoundedRectangle(cornerRadius: 25)
                                        }
                                    }
                                    
                                    .opacity(cards.contains(card) ? 1 : 0)
                                    
                                }
                            }
                        }
                    }
                    .padding()
                    .navigationTitle(String(format: "%.1f",elapsedTime))
                    
                }
            }
        }
    }
    func start() {
        // Initialize the game state
        startTime = Date()
        elapsedTime = 0
        done = false
        
        // Start the timer
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            elapsedTime = Date().timeIntervalSince(startTime)
        }
        
        // Prepare the cards and sides
        shuffledFullCards = fullCards.shuffled()
        cards = Array(shuffledFullCards.prefix(options.amount))
        count = options.amount
        for side in sides {
            shuffledCards[side] = cards.shuffled()
        }
    }
}
#Preview {
    MatchView(fullCards: [Card(sides: ["a":"1","b":"4","c":"3"]), Card(sides: ["a":"3","b":"4","c":"5"]), Card(sides: ["a":"2","b":"4","c":"6"])], options: MatchOptions(), sides: MatchSides(sideDict: ["sides":["b","c"]]))
        .preferredColorScheme(.dark)
}
