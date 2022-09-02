//
//  ArtistsView.swift
//  VLC-watchOS WatchKit Extension
//
//  Created by Rory Clear on 02/09/2022.
//  Copyright © 2022 VideoLAN. All rights reserved.
//

import SwiftUI
import AVFoundation

struct ArtistsView: View {
    
    var body: some View {
        List(FileControls.shared.getAllArtists()) {
            artist in ArtistRow(artist: artist)
        }
    }
    
    init(){
    }
            
}

struct Artist: Identifiable {
    let id = UUID()
    let name: String
}

struct ArtistRow: View {
    var artist: Artist
    var body: some View {
        NavigationLink("\(artist.name)", destination: ArtistSongsView(a: artist.name))
    }
}

struct ArtistsView_Previews: PreviewProvider {
    static var previews: some View {
        ArtistsView()
    }
}
