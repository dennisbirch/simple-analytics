//
//  ContentView.swift
//  Shared
//
//  Created by Dennis Birch on 3/23/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ScrollView {
            MainView()
        }
        .onAppear{
            DemoAnalytics.addAnalyticsItem("Display main view")
        }
    }
}

struct FirstButtonGroup: View {
    var body: some View {
        VStack {
            PlaySoundButton(title: "Ring Bell")
            PlaySoundButton(title: "Horn Blaring")
            PlaySoundButton(title: "Foghorn Warning")
            PlaySoundButton(title: "Car Revving")
            PlaySoundButton(title: "Dog Barking")
            PlaySoundButton(title: "Fire Siren")
            PlaySoundButton(title: "Oven Timer")
        }
    }
}

struct SecondButtonGroup: View {
    var body: some View {
        VStack {
            PlaySoundButton(title: "Car Door Slam")
            PlaySoundButton(title: "Heavy Breathing")
            PlaySoundButton(title: "Soft Sigh")
            PlaySoundButton(title: "Thunderclap")
            PlaySoundButton(title: "Ocean Wave Crashing")
            PlaySoundButton(title: "Repeat Last")
            PlaySoundButton(title: "Repeat Last (Other)")
        }
    }
}

struct PlaySoundButton: View {
    let title: String
    var body: some View {
        Button(title) {
            playSound(title)
        }
        .padding()
    }
    
    private func playSound(_ title: String) {
        DemoAnalytics.addAnalyticsItem("Play sound: \(title)")
        // do whatever else this button should do
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
