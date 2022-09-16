//
//  SongsView.swift
//  VLC-watchOS WatchKit Extension
//
//  Created by Rory Clear on 02/09/2022.
//  Copyright © 2022 VideoLAN. All rights reserved.
//

import SwiftUI
import AVFoundation
import WatchKit

struct SongsView: View {
    @State private var songs: [Song] = FileControls.shared.getAllMp3s()
    
    var body: some View {
        List {
            ForEach(songs, id: \.self) {
                SongRow(song: $0)
            }.onDelete(perform: removeRows)
        }
    }
    
    func removeRows(at offsets: IndexSet) {
        deleteSong(song: songs[offsets.first!])
        songs.remove(atOffsets: offsets)
    }
    
}

func deleteSong(song: Song) {
    FileControls.shared.deleteSong(song: song)
}

struct SongRow: View {
    var song: Song
    var body: some View {
        Button(action: {
            SoundPlaying.shared.resetShuffleAndRepeat()
            SoundPlaying.shared.playSound(song: song)
            SoundPlaying.shared.shuffleOrder()
            }) { // Dummy button
                VStack(alignment: .leading) {
                    Text("\(song.name)").lineLimit(1)
                    Text("\(song.artist)").lineLimit(1).font(.system(size: 12)).foregroundColor(.gray) //roryclear change to same colour as phone app? / font
                }
        }.background(NavigationLink("",destination: CustomNowPlayingView2()))
    }
}

struct SongsView_Previews: PreviewProvider {
    static var previews: some View {
        SongsView()
    }
}
