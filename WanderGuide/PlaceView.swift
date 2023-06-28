//
//  PlaceView.swift
//  WanderGuide
//
//  Created by Daveed Balcher on 6/21/23.
//

import MapKit
import SwiftUI

class Place {
    let locationTitle: String
    let tourDescription: String
    let categoryName: String
    let storyDescription: String
    let coordinates: CLLocationCoordinate2D?
    
    init(locationTitle: String, categoryName: String, tourDescription: String, storyDescription: String, coordinates: CLLocationCoordinate2D? = nil) {
        self.locationTitle = locationTitle
        self.categoryName = categoryName
        self.tourDescription = tourDescription
        self.storyDescription = storyDescription
        self.coordinates = coordinates
    }
}

enum SwipeDirection {
    case left, right
}

struct PlaceView: View {
    var place: Place
    var tourCoordinates: [CLLocationCoordinate2D]
    var index: Int
    
    private var placeCoordinates: CLLocationCoordinate2D {
        tourCoordinates[index]
    }
    
    @GestureState private var translation: CGFloat = 0
    
    var didSwipeCompletion: ((SwipeDirection) -> Void)
    
    var body: some View {
        ScrollView {
                HStack {
                    if index > 0 {
                        Button {
                            didSwipeCompletion(.left)
                        } label: {
                            Image(systemName: "arrow.left")
                                .font(.title)
                                .padding()
                        }
                    }
                    
                    Spacer()
                    
                    if index < tourCoordinates.count-1 {
                        Button {
                            didSwipeCompletion(.right)
                        } label: {
                            Image(systemName: "arrow.right")
                                .font(.title)
                                .padding()
                        }
                    }
                }
                .foregroundColor(.blue)
                .padding(.bottom, -24)
            
            VStack(alignment: .leading, spacing: 20) {
                Text(place.locationTitle)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Text(place.tourDescription)
                    .font(.headline)
                    .padding(.top, -24)
                    .padding([.leading, .trailing], 16)
                
                Text(place.categoryName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Color.gray))
                    .foregroundColor(.white)
                    .padding(.leading, 16)
                    .padding(.top, 8)
                    .padding(.bottom, -20)
                
                Text(place.storyDescription)
                    .font(.body)
                    .padding([.leading, .top, .trailing], 16)
                
                ZStack(alignment: .topTrailing) {
                    Map(coordinateRegion: .constant(MKCoordinateRegion(center: placeCoordinates, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))), showsUserLocation: true) 
                    .frame(height: 300)
                    .ignoresSafeArea(edges: .all)
                    .disabled(true)

                    Button(action: {
                        // Generate the Google Maps URL with coordinates
                        if let googleMapsURL = getGoogleMapsURL(withCoordinates: tourCoordinates, startIndex: index) {
                            if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
                                UIApplication.shared.open(googleMapsURL, options: [:], completionHandler: nil)
                            } else {
                                print("Can't use comgooglemaps://")
                            }
                        }
                        
                    }) {
                        Text("Navigate")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(Color.blue))
                            .foregroundColor(.white)
                    }
                    .padding()
                }
            }
        }
        .gesture(
            DragGesture()
                .updating($translation) { value, state, _ in
                    state = value.translation.width
                }
                .onEnded { value in
                    let gestureThreshold: CGFloat = 100
                    if value.translation.width > gestureThreshold {
                        didSwipeCompletion(.left)
                    } else if value.translation.width < -gestureThreshold {
                        didSwipeCompletion(.right)
                    }
                }
        )
    }
    
    private func getGoogleMapsURL(withCoordinates coordinates: [CLLocationCoordinate2D], startIndex: Int) -> URL? {
        guard startIndex >= 0, startIndex < coordinates.count else {
            return nil
        }
        
        let subCoordinates = Array(coordinates[startIndex..<coordinates.count])
        
        guard let firstCoordinate = subCoordinates.first else {
            return nil
        }
        
        let waypointCoordinates = subCoordinates.dropFirst()
        
        var googleMapsURLString = "comgooglemaps://?saddr=&daddr="
        
        for coordinate in waypointCoordinates {
            googleMapsURLString += "\(coordinate.latitude),\(coordinate.longitude)+to:"
        }
        
        googleMapsURLString += "\(firstCoordinate.latitude),\(firstCoordinate.longitude)"
        
        let googleMapsURL = URL(string: googleMapsURLString)
        
        return googleMapsURL
    }

}

struct PlaceView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceView(place: Place(locationTitle: "Halsey Institute of Contemporary Art", categoryName: "Art Gallery", tourDescription: "End your tour with something sweet from Kaminsky's. This cozy café serves up decadent desserts that are well worth a visit.", storyDescription: "Welcome to the Halsey Institute of Contemporary Art, a hub of creativity and innovation. This gallery showcases thought-provoking exhibitions featuring emerging and established contemporary artists from around the world. Prepare to be captivated by the diverse range of artistic expressions, from paintings and sculptures to multimedia installations. The Halsey Institute encourages dialogue and reflection, inviting visitors to explore the cutting-edge art that challenges conventional boundaries.", coordinates: CLLocationCoordinate2D(latitude: 39.9582, longitude: -75.1720)), tourCoordinates: [CLLocationCoordinate2D(latitude: 39.9582, longitude: -75.1720), CLLocationCoordinate2D(latitude: 39.9582, longitude: -75.1720), CLLocationCoordinate2D(latitude: 39.9582, longitude: -75.1720)], index: 0) { _ in }
    }
}
