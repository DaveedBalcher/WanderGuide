//
//  MainView.swift
//  WanderGuide
//
//  Created by Daveed Balcher on 6/23/23.
//

import CoreLocation
import SwiftUI

struct MainView: View {
    @ObservedObject private var vm = MainViewModel()

    var body: some View {
        VStack {
            switch vm.appScreen {
            case .intro:
                Text("WANDER GUIDE")
                    .font(.largeTitle)
                    .bold()
            case .loading:
                Text("Loading")
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            case .quiz(quiz: let quiz, index: let index):
                QuizView(quiz: quiz) { answer in
                    // Update prompt with answers
                    vm.submit(answer: answer, for: index)
                }
            case .tour(place: let place, index: let index):
                PlaceView(place: place, tourCoordinates: vm.tourCoordinates, index: index) { swipeDirection in
                    vm.navigateTo(placeIndex: swipeDirection == .left ? index-1 : index+1)
                }
            case .error(message: let message):
                Text(message)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
