//
//  ContentView.swift
//  VLC-watchOS WatchKit Extension
//
//  Created by Rory Clear on 02/09/2022.
//  Copyright © 2022 VideoLAN. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        List {
            
            NavigationLink("Artists", destination: ArtistsView())
            NavigationLink("Albums", destination: AlbumsView())
            NavigationLink("Songs", destination: SongsView())
            Button("Genres", action: FileControls.shared.deleteAllMp3s) //roryclear change later
        }
    }
    
    init() {
        FileControls.shared.connectToPhone()
    }
}


func printStuff() {
    print("roryclear")
    FileControls.shared.printSomething()
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
