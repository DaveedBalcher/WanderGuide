//
//  ContentView.swift
//  WanderGuide
//
//  Created by Daveed Balcher on 6/21/23.
//

import SwiftUI

class Quiz {
    var question: String
    var callToAction: String
    var options: [String]
    
    init(question: String, callToAction: String, options: [String]) {
        self.question = question
        self.callToAction = callToAction
        self.options = options
    }
}

struct QuizView: View {
    var quiz: Quiz
    var completeWithSelection: ((String)->Void)
    
    var body: some View {
        VStack {
            Text(quiz.question)
                .font(.title)
                .fontWeight(.bold)
                .padding()
            Text("\(quiz.callToAction): ")
                .font(.headline)
                .fontWeight(.bold)
                .padding()
            
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
                ForEach(quiz.options, id: \.self) { option in
                    Button {
                        completeWithSelection(option)
                    } label: {
                        Text(option)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
            }
        
            Spacer()
        }
        .frame(height: 600)
        .padding()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        QuizView(quiz: Quiz(question: "What is your main interest?", callToAction: "Choose one:", options: ["History", "Architecture", "Art", "Food", "Nature", "Culture"])) { _ in }
    }
}
