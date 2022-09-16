//
//  Song.swift
//  VLC-watchOS WatchKit Extension
//
//  Created by Rory Clear on 02/09/2022.
//  Copyright © 2022 VideoLAN. All rights reserved.
//

import Foundation

struct Song: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let artist: String
    let album: String
    let url: URL
    let number: Int
}
