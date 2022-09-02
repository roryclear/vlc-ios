//
//  AlbumsView.swift
//  VLC-watchOS WatchKit Extension
//
//  Created by Rory Clear on 02/09/2022.
//  Copyright © 2022 VideoLAN. All rights reserved.
//

import SwiftUI

struct AlbumsView: View {
    
    var body: some View {
        List(FileControls.shared.getAllAlbums()) {
            album in AlbumRow(album: album)
        }
    }
    
    init(){
    }
            
}

struct Album: Identifiable {
    let id = UUID()
    let name: String
    let artist: String
    let artwork: UIImage
}

struct AlbumRow: View {
    var album: Album
    var body: some View {
        Button(action: {}) { // Dummy button
            HStack {
            Image(uiImage: album.artwork).resizable().frame(minWidth: 30, idealWidth: 30, maxWidth: 30, minHeight: 30, idealHeight: 30, maxHeight: 30, alignment: .init(horizontal: .leading, vertical: .center))
                VStack(alignment: .leading) {
                    Text("\(album.name)").lineLimit(1)
                    Text("\(album.artist)").lineLimit(1).font(.system(size: 12)).foregroundColor(.gray) //roryclear change to same colour as phone app? / font
                }
            }
        }.background(NavigationLink("",destination: AlbumSongsView(a: album.name)))
    }
}

struct AlbumsView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumsView()
    }
}
