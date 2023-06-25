//
//  MainViewModel.swift
//  WanderGuide
//
//  Created by Daveed Balcher on 6/25/23.
//

import Foundation
import CoreLocation

enum AppScreen {
    case intro,
         loading,
         quiz(quiz: Quiz, index: Int),
         tour(place: Place, index: Int),
         error(message: String)
}

class MainViewModel: ObservableObject {
    @Published var appScreen: AppScreen = .intro
    
    var quizes: [Quiz] = [
        Quiz(question: "What's the focus you'd like for your walk?", callToAction: "Choose one", options: ["History", "Architecture", "Art", "Food", "Nature", "Culture"]),
        Quiz(question: "Want an extra touch to your experience?", callToAction: "Choose one", options: ["None", "History", "Architecture", "Art", "Food", "Nature", "Culture"]),
        Quiz(question: "How long would you like to walk?", callToAction: "Pick a duration", options: ["1 hour", "2 hours", "3 hours", "5 hours", "8 hours"]),
        Quiz(question: "How far do you feel like walking?", callToAction: "Choose a distance", options: ["1/2 mile", "1 mile", "2 miles", "3 miles", "5 miles", "8 miles"]),
        Quiz(question: "What's your walking distance preference?", callToAction: "Choose one", options: ["1/2 mile", "1 mile", "2 miles", "3 miles", "5 miles", "8 miles"]),
        Quiz(question: "How much moolah are you willing to spend on activities?", callToAction: "Choose one", options: ["No Money", "$10", "$25", "$50", "$100", "No Limit"])
    ]
    
    var answers: [String]

    var places: [Place] = [
        Place(locationTitle: "Charleston City Market", categoryName: "Historic Market", tourDescription: "Begin your day with a visit to the historic Charleston City Market. It's a great spot to experience Charleston's vibrancy and pick up a snack.", storyDescription: "The Charleston City Market is a historic market complex that dates back to the 1790s. It originally consisted of a Meat Market, Beef Market, and a Fish Market. Its architectural design showcases an interesting mix of Greek Revival and Roman architectural styles. The four block-long sheds, with their open sides and towering columns, have been the commercial hub of the city for centuries.", coordinates: CLLocationCoordinate2D(latitude: 32.7811, longitude: -79.9297)),
        Place(locationTitle: "Carriage Tour", categoryName: "Guided Tour", tourDescription: "Rather than walking, take a carriage tour from one of the companies near the Market. You'll be able to see and learn about the architectural details of the historic district without having to walk.", storyDescription: "While the carriage tour is more of an experience than a place, it's your window into the architectural history of Charleston. The guide will provide detailed information about a variety of architectural styles seen in the city, from the grand mansions in the South of Broad district to the quaint and colorful houses of Rainbow Row.", coordinates: CLLocationCoordinate2D(latitude: 32.7795, longitude: -79.9364)),
        Place(locationTitle: "Rainbow Row", categoryName: "Historic Houses", tourDescription: "Post carriage tour, visit Rainbow Row - 13 colorful historic houses, an iconic Charleston sight, known for its Georgian architecture.", storyDescription: "Rainbow Row is a series of thirteen brightly colored, Georgian-style row houses. They date back to 1740 and represent the longest cluster of Georgian row houses in the United States. After being restored in the early 20th century, the owners painted the houses in pastel colors, leading to the name 'Rainbow Row'.", coordinates: CLLocationCoordinate2D(latitude: 32.7715, longitude: -79.9282)),
        Place(locationTitle: "Waterfront Park", categoryName: "Park", tourDescription: "Take a leisurely stroll along the park for views of Charleston Harbor, and don't miss the famous Pineapple Fountain.", storyDescription: "Waterfront Park is a testament to modern landscape architecture. Opened in 1990, the park was built on reclaimed land that was once marshes and docks. The Pineapple Fountain, a centerpiece of the park, embodies the city's Southern hospitality. The architecture of the park is designed to seamlessly integrate with the historic landscape of the city.", coordinates: CLLocationCoordinate2D(latitude: 32.7715, longitude: -79.9236)),
        Place(locationTitle: "Husk Restaurant", categoryName: "Restaurant", tourDescription: "For a gastronomical experience, head to Husk, one of Charleston's most renowned restaurants, known for its unique Southern cuisine.", storyDescription: "Housed in a late 19th-century Victorian mansion, Husk is a visual and culinary delight. The building is beautifully restored, featuring intricate woodworking and period-specific architectural details throughout. The restaurant adeptly combines the old-world charm of its architectural surroundings with a modern, southern-inspired menu.", coordinates: CLLocationCoordinate2D(latitude: 32.7680, longitude: -79.9307)),
        Place(locationTitle: "Nathaniel Russell House Museum", categoryName: "Historic House Museum", tourDescription: "Visit this historic house museum for a glimpse into Antebellum life and marvel at the stunning neoclassical architecture.", storyDescription: "The Nathaniel Russell House, built in 1808, is considered one of the finest examples of neoclassical architecture in the United States. It is well-known for its magnificent free-flying staircase that ascends three stories, its gracefully proportioned rooms, and elaborate decorative plasterwork. The house stands as a testament to the wealthy merchant class of Charleston's past.", coordinates: CLLocationCoordinate2D(latitude: 32.7695, longitude: -79.9307)),
        Place(locationTitle: "Kaminsky's Dessert Cafe", categoryName: "Cafe", tourDescription: "End your tour with something sweet from Kaminsky's. This cozy café serves up decadent desserts that are well worth a visit.", storyDescription: "Kaminsky's occupies a charming, rustic building in the bustling Deco District. While it may not be as historically significant as some other buildings, its cozy and warm interiors, along with a vintage-inspired decor, provide a comforting environment that complements its deliciously sweet offerings.", coordinates: CLLocationCoordinate2D(latitude: 32.7908, longitude: -79.9367))
        ]
    
    var tourCoordinates: [CLLocationCoordinate2D] {
        places.compactMap { $0.coordinates }
    }
    
    init() {
        self.answers = Array(repeating: "", count: quizes.count)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [self] in
            self.appScreen = .quiz(quiz: self.quizes[0], index: 0)
        }
    }
    
    func submit(answer: String, for index: Int) {
        addAnswer(answer: answer, for: index)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            navigateToNextQuiz(answer: answer, index: index)
        }
    }
    
    private func addAnswer(answer: String, for index: Int) {
        answers[index] = answer
    }
    
    private func navigateToNextQuiz(answer: String, index: Int) {
        let currentQuizIndex = index+1
        if currentQuizIndex < quizes.count {
            let nextQuiz = quizes[currentQuizIndex]
            nextQuiz.options = nextQuiz.options.filter { $0 !=  answer }
            self.appScreen = .quiz(quiz: nextQuiz, index: currentQuizIndex)
        } else {
            navigateToTour()
        }
    }
    
    private func navigateToTour() {
        self.appScreen = .loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.appScreen = .tour(place: self.places[0], index: 0)
        }
    }
    
    func navigateTo(placeIndex index: Int) {
        if index >= 0,
           index < places.count {
            appScreen = .tour(place: places[index], index: index)
        }
    }
}
