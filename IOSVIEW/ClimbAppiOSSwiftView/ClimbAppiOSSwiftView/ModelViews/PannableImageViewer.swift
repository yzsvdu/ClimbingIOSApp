//
//  SelectStartHoldViewer.swift
//  ClimbAppiOSSwiftView
//
//  Created by Vincent Duong on 2/8/24.
//

import SwiftUI

struct PannableImageViewer: View {
    let uploadedData: GeneratedData
    let holdVisuals: [HoldVisual]
    let onTapGesture: (HoldVisual) -> Void
    
    @State private var animate: Bool = false
    var selectedHolds: [Int]
    
    init(uploadedData: GeneratedData, holdVisuals: [HoldVisual], onTapGesture: @escaping (HoldVisual) -> Void, selectedHolds: [Int]) {
        self.uploadedData = uploadedData
        self.holdVisuals = holdVisuals
        self.onTapGesture = onTapGesture
        self.selectedHolds = selectedHolds
    }
    
    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: false) {
            ZStack {
                Image(uiImage: uploadedData.image);
                DarkOverlay(size: uploadedData.image.size)
                HoldIndicators()
            }
        }
    }
    
    /// Dark Transparent Rectangle
    func DarkOverlay(size: CGSize) -> some View {
        Rectangle()
            .foregroundColor(Color.black.opacity(0.84))
            .frame(width: size.width, height: size.height)
        
    }
    
    /// Group of Hold Visuals
    func HoldIndicators() -> some View {
        ForEach(0..<holdVisuals.count, id: \.self) { index in
            let visual: HoldVisual = holdVisuals[index]
            holdIndicatorView(visual: visual)
        }
    }
    
    /// Individual Hold Visual
    func holdIndicatorView(visual: HoldVisual) -> some View {
        Rectangle()
            .fill(Color.clear)
            .overlay(
                Image(uiImage: visual.image)
                    .opacity(animate && selectedHolds.contains(visual.hold.id) ? 1 : 0.6)
                    .animation(
                        selectedHolds.contains(visual.hold.id) ?
                        Animation.easeInOut(duration: 0.3).repeatForever(autoreverses: true) :
                            .default
                    )
                    .onAppear {
                        animate = true
                    }
                
            )
            .frame(
                width: visual.width,
                height: visual.height
            )
            .offset(
                x: visual.hold.box.xMax + visual.xOffset,
                y: visual.hold.box.yMax + visual.yOffset
            )
            .onTapGesture {
                onTapGesture(visual)
            }
    }
}
