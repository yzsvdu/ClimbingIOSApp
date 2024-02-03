//
//  SelectRouteView.swift
//  ClimbAppiOSSwiftView
//
//  Created by Ryan Phung on 2/1/24.
//

import SwiftUI

struct SelectRouteView: View {
    // SelectRouteView is the parent and is incharge of creating routeHolds array
    @State private var routeHolds: [Int] = []
//    @Binding var routeHolds: [Int]
    @Binding var startHolds: [Int]
    let image: UIImage
    let predicatedHolds: PredictedHolds
    let predictedMasks: Masks
    
    var body: some View {
        VStack {
            PannableImageView(routeHolds: $routeHolds, startHolds: $startHolds, allowSelectStartHolds: false, image: image, showMasks: true, showOverlay: true, predictedHolds: predicatedHolds, predictedMasks: predictedMasks)
        }
        .navigationTitle("Select Route Holds")
        .navigationBarItems(
            trailing: Button(action: {
                Task {
                    do {
                        try await routeFinished()
                    } catch {
                        print("Erorr: \(error)")
                    }
                }
            }) {
                Text("Done")
            }
        )
        
        
    }
    
    func routeFinished() async throws {
        print("File: \(#file) Line: \(#line)")
        print("finished route: \(routeHolds)")
    }
}

/*
 #Preview {
 SelectRouteView()
 }
 */
