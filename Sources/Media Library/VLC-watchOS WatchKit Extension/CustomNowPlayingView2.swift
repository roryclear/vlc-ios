//
//  CustomNowPlayingView2.swift
//  VLC-watchOS WatchKit Extension
//
//  Created by Rory Clear on 02/09/2022.
//  Copyright © 2022 VideoLAN. All rights reserved.
//

import SwiftUI
import WatchKit
import UIKit

struct CustomNowPlayingView2: View {
    
    //@State var shuffleText: String
    @State var shuffleSymbol: UIImage
    @State var repeatSymbol: UIImage
    @State var shuffleButtonColor: Color
    @State var repeatButtonColor: Color
    var body: some View {
        TabView {
            NowPlayingView().padding(EdgeInsets(top: 1, leading: 0, bottom: 0, trailing: 0)) //roryclear fix this properly at some stage
            HStack {
                Button {toggleShuffle()} label: {
                    Image(uiImage: shuffleSymbol).foregroundColor(.white)
                }.buttonStyle(BorderedButtonStyle(tint: shuffleButtonColor))
            //Button(shuffleText,action: toggleShuffle).frame(width: 90, height: 50, alignment: .init(horizontal: .trailing, vertical: .center))
                Button {toggleRepeat()} label: {
                    Image(uiImage: repeatSymbol)
                }.buttonStyle(BorderedButtonStyle(tint: repeatButtonColor))
            }
        }
    }
    
    init() { // roryclear init is not called when the user clicks, but is called when the user scrolls over them in SongsView
        shuffleSymbol = UIImage(named: "shuffle")! //roryclear don't need to init here
        shuffleButtonColor = .orange.opacity(0)
        repeatButtonColor = .orange.opacity(0)
        repeatSymbol = UIImage(named: "repeat")!
    }
    
    func toggleShuffle() {
        print("roryclear toggleshuffle")
        if SoundPlaying.shared.shuffle {
            shuffleButtonColor = .orange.opacity(0)
        }else {
            shuffleButtonColor = .orange.opacity(150)
        }
        SoundPlaying.shared.toggleShuffle()
    }
    
    func toggleRepeat() {
        switch SoundPlaying.shared.repeatMode {
        case .off:
            repeatSymbol = UIImage(named: "repeat")!
            repeatButtonColor = .orange.opacity(150)
        case .repeatAll:
            repeatSymbol = UIImage(named: "repeatOne")!
            repeatButtonColor = .orange.opacity(150)
        case .repeatOne:
            repeatSymbol = UIImage(named: "repeat")!
            repeatButtonColor = .orange.opacity(0)
        }
        SoundPlaying.shared.changeRepeatMode()
    }
    
}

struct CustomNowPlayingView2_Previews: PreviewProvider {
    static var previews: some View {
        CustomNowPlayingView2()
    }
}
