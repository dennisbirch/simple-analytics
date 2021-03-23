//
//  MainView.swift
//  SimpleAnalyticsDemo (iOS)
//
//  Created by Dennis Birch on 3/23/21.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            FirstButtonGroup()
            SecondButtonGroup()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
