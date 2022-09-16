//
//  AlbumSongsView.swift
//  VLC-watchOS WatchKit Extension
//
//  Created by Rory Clear on 02/09/2022.
//  Copyright © 2022 VideoLAN. All rights reserved.
//

import SwiftUI
import AVFoundation
import WatchKit

struct AlbumSongsView: View {
    var album: String
    var body: some View {
        List(FileControls.shared.getAllMp3s(album: album)) {
            song in SongRow(song: song)
        }
    }
    
    init(a: String) {
        album = a
    }
    
    
}

struct AlbumSongRow: View {
    var song: Song
    var body: some View {
        Button("\(song.name)", action: {
            SoundPlaying.shared.resetShuffleAndRepeat()
            SoundPlaying.shared.playSound(song: song)
            SoundPlaying.shared.shuffleOrder()
        }).background(NavigationLink("", destination: NowPlayingView()))
    }
}

struct AlbumSongsView_Previews: PreviewProvider {
    static var previews: some View {
        SongsView()
    }
}
