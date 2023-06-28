//
//  DataFetchingService.swift
//  WanderGuide
//
//  Created by Daveed Balcher on 6/26/23.
//

import Foundation
import CoreLocation

// MARK: - TourRequest
struct TourRequest: Codable {
    let location: String
    let interests: String
    let budget: Int
    let duration: Int
    let distance: Int
    let startTime: String
    
    enum CodingKeys: String, CodingKey {
        case location, interests, budget, duration, distance
        case startTime = "start_time"
    }
}

// MARK: - TourResponse
struct TourResponse: Codable {
//    let walkingTour: Tour
//
//    enum CodingKeys: String, CodingKey {
//        case walkingTour = "walking_tour"
//    }
//}
//
//
//struct Tour: Codable {
    let tourName: String?
    let startTime: String?
    let totalDuration: String?
    let totalDistance: String?
    let budget: String?
    let locations: [Location]
    
    enum CodingKeys: String, CodingKey {
        case tourName = "tour_name"
        case startTime = "start_time"
        case totalDuration = "total_duration"
        case totalDistance = "total_distance"
        case budget
        case locations
    }
}

struct Location: Codable {
    let locationName: String
    let category: String
    let story: String
    let suggestedVisitDuration: String
    let geolocation: Geolocation
    
    enum CodingKeys: String, CodingKey {
        case locationName = "location_name"
        case category
        case story
        case suggestedVisitDuration = "suggested_visit_duration"
        case geolocation
    }
}

struct Geolocation: Codable {
    let latitude: Double
    let longitude: Double
}


// MARK: - ValidationError
struct ValidationError: Codable {
    let loc: [String]
    let msg: String
    let type: String
}

// MARK: - HTTPValidationError
struct HTTPValidationError: Codable {
    let detail: [ValidationError]
}

struct QuizToTourRequestMapper {
    static func map(answers: [String]) -> TourRequest {
        let location = "Charleston, SC"
        let startTime = "morning"
        
        var interests = answers[0].lowercased()
        if answers[1] != "None" {
            interests = interests + ", " + answers[1].lowercased()
        }
        let duration = Int(answers[2].lowercased().replacingOccurrences(of: " hours", with: "").replacingOccurrences(of: " hour", with: "")) ?? 0
        let distance = Int(answers[3].lowercased().replacingOccurrences(of: " miles", with: "").replacingOccurrences(of: " mile", with: "")) ?? 0
        let budget = Int(answers[4].lowercased().replacingOccurrences(of: "$", with: "")) ?? (answers[5] == "no limit" ? 1000 : 0)
        
        // Print the values to check them
        print("location: \(location)")
        print("interests: \(interests)")
        print("duration: \(duration)")
        print("distance: \(distance)")
        print("budget: \(budget)")
        print("startTime: \(startTime)")
        
        return TourRequest(location: location, interests: interests, budget: budget, duration: duration, distance: distance, startTime: startTime)
    }
}

class DataFetchingService {
    func fetchData(answers: [String], completion: @escaping ([Place]?, Error?) -> Void) {
        let request = QuizToTourRequestMapper.map(answers: answers)
        
        guard let url = URL(string: "https://wander-api.onrender.com/tour/") else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "location": request.location,
            "interests": request.interests,
            "budget": request.budget,
            "duration": request.duration,
            "distance": request.distance,
            "start_time": request.startTime
        ]
        
        urlRequest.httpBody = parameters
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        urlRequest.timeoutInterval = 150
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let data = data {
                
                if let string = String(data: data, encoding: .utf8) {
                    print("jsonString: ", string)
                }
                let decoder = JSONDecoder()
                do {
                    let tour = try decoder.decode(TourResponse.self, from: data)
                    print("TourResponse: ", tour)
                    
                    let places = tour.locations.map { location -> Place in
                        return Place(
                            locationTitle: location.locationName,
                            categoryName: location.category,
                            tourDescription: tour.tourName ?? "",
                            storyDescription: location.story,
                            coordinates: CLLocationCoordinate2D(latitude: location.geolocation.latitude, longitude: location.geolocation.longitude)
                        )
                    }
                    completion(places, nil)
                } catch {
                    print("Error decoding JSON: \(error)")
                    completion(nil, error)
                }
            }
        }.resume()
    }
    
//    private func coordinatesFromGeolocation(_ geolocation: String) -> CLLocationCoordinate2D? {
//        let components = geolocation.components(separatedBy: ", ")
//        guard components.count == 2 else { return nil }
//        let latitude: String = components[0]
//        let longitude: String = components[1]
//        var latDegrees = Double(latitude.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789.").inverted))
//        var lonDegrees = Double(longitude.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789.").inverted))
//        
//        if latitude.hasSuffix("S") || latitude.hasSuffix("s") {
//            latDegrees = -latDegrees!
//        }
//        
//        if longitude.hasSuffix("W") || longitude.hasSuffix("w") {
//            lonDegrees = -lonDegrees!
//        }
//        
//        if let latDegrees = latDegrees, let lonDegrees = lonDegrees {
//            return CLLocationCoordinate2D(latitude: latDegrees, longitude: lonDegrees)
//        } else {
//            return nil
//        }
//    }
}
