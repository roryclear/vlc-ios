//
//  SoundPlaying.swift
//  VLC-watchOS WatchKit Extension
//
//  Created by Rory Clear on 02/09/2022.
//  Copyright © 2022 VideoLAN. All rights reserved.
//

import AVFoundation
import MediaPlayer
import UIKit

class SoundPlaying {
    enum RepeatMode: Int, CaseIterable {
        case off
        case repeatAll
        case repeatOne
    }
        
    var nowPlayingInfo = [String: Any]()
    var setup = false
    var skipForwardInterval: NSNumber = 10
    var currentIndex: Int = 0
    var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    
    static let shared = SoundPlaying()

    var shuffle = false
    var repeatMode = RepeatMode.off
    var shuffledOrder: [Int] = []
    
    func playSound(song: Song) {
        // Set up the session.
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(AVAudioSession.Category.playback,
                                    mode: .default,
                                    policy: .longForm,
                                    options: [])
        } catch let error {
            fatalError("*** Unable to set up the audio session: \(error.localizedDescription) ***")
        }
        do {
        audioPlayer = try AVAudioPlayer(contentsOf: song.url)
            audioPlayer.enableRate = true //if podcast?
            
            // Activate and request the route.
            session.activate(options: []) { [self] (success, error) in
                guard error == nil else {
                    print("*** An error occurred: \(error!.localizedDescription) ***")
                    // Handle the error here.
                    return
                }
                
                // Play the audio file.
                if(!setup)
                {
                setupMediaPlayerNotificationView()
                setup = true
                }
                setupNotificationView(song: song)
                audioPlayer.play()
                

            }
            if !shuffle { //roryclear only need to do this once! fix later
            var i = 0
            for s in FileControls.shared.playlist {
                if s.url == song.url {
                    currentIndex = i
                }
                i += 1
            }
            }
        } catch {
            
        }
        
        let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.fireTimer), userInfo: nil, repeats: true)
        
       // try? audioPlayer = AVAudioPlayer(contentsOf: url)
       // audioPlayer?.play()
    }
    
    func resetShuffleAndRepeat() { // roryclear quick hack to fix not remembering them properly ?
        shuffle = false
        repeatMode = .off
    }
    
    @objc func fireTimer() {
        let commandCenter = MPRemoteCommandCenter.shared()
        if(audioPlayer.duration - audioPlayer.currentTime < 1.0) //roryclear this could be a lot better
        {
            self.nextTrack()
        }
    }
    
    func shuffleOrder() {
        shuffledOrder = []
        print("roryclear shuffling order")
        for i in 0..<FileControls.shared.playlist.count {
            shuffledOrder.append(i)
        }
        shuffledOrder.shuffle()
        let temp = shuffledOrder[0]
        let currentPosInShuffledOrder = shuffledOrder.firstIndex(of: currentIndex)
        shuffledOrder[0] = shuffledOrder[currentPosInShuffledOrder!]
        shuffledOrder[currentPosInShuffledOrder!] = temp
    }
    
    func toggleShuffle() {
        print("roryclear soundplaying shuffle toggled")
        shuffle = !shuffle
        if(shuffle) {
            shuffleOrder()
            currentIndex = 0
        }else{
            currentIndex = shuffledOrder[currentIndex]
        }
    }
    
    func changeRepeatMode() {
        switch repeatMode {
        case .off:
            repeatMode = .repeatAll
        case .repeatAll:
            repeatMode = .repeatOne
        case .repeatOne:
            repeatMode = .off
        }
    }
    
    func pauseSound(){
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer.currentTime
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        audioPlayer.pause()
    }
    
    func resumeSound(){
        audioPlayer.play()
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer.currentTime
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    
    func nextTrack() {
        print("roryclear next track shuffledSongPlaylistIndex = ", currentIndex)
        if repeatMode == .repeatOne {
        } else if(currentIndex < FileControls.shared.playlist.count - 1)
        {
            currentIndex += 1
        }else {
            if repeatMode == .repeatAll {
                currentIndex = 0
            }
        }
        if shuffle {
            playSound(song: FileControls.shared.playlist[shuffledOrder[currentIndex]])
        } else {
            playSound(song: FileControls.shared.playlist[currentIndex])
        }
        
    }
        
    func prevTrack() {
            if audioPlayer.currentTime < 5.0 {
                if currentIndex > 0 {
                currentIndex -= 1
                } else if repeatMode == .repeatAll {
                    currentIndex = shuffledOrder.count - 1
                }
            }
            if shuffle {
            playSound(song: FileControls.shared.playlist[shuffledOrder[currentIndex]])
            } else {
                playSound(song: FileControls.shared.playlist[currentIndex])
            }
    }
    
    
    
    //command center???
    //https://medium.com/@varundudeja/showing-media-player-system-controls-on-notification-screen-in-ios-swift-4e27fbf73575
       func setupMediaPlayerNotificationView() {
            let commandCenter = MPRemoteCommandCenter.shared()
                
            //get podcast controls??
            commandCenter.skipForwardCommand.isEnabled = false
            commandCenter.skipBackwardCommand.isEnabled = false
                
            commandCenter.nextTrackCommand.isEnabled = true
            commandCenter.previousTrackCommand.isEnabled = true
                
                //commandCenter.changePlaybackRateCommand.isEnabled = true
                //commandCenter.changePlaybackRateCommand.supportedPlaybackRates = playbackRates
            
            commandCenter.playCommand.addTarget { [unowned self] event in
                self.resumeSound()
                return .success
            }
            
            commandCenter.pauseCommand.addTarget { [unowned self] event in
                self.pauseSound()
                return .success
            }
               
           commandCenter.nextTrackCommand.addTarget { [unowned self] event in
               self.nextTrack()
               return .success
           }
           
           commandCenter.previousTrackCommand.addTarget { [unowned self] event in
               self.prevTrack()
               return .success
           }
        
    }
    
    func duration(for resource: URL) -> Double {
        let asset = AVURLAsset(url: resource)
        return Double(CMTimeGetSeconds(asset.duration))
    }
    
    func getNextTrackTitle() -> String {
        if (currentIndex < FileControls.shared.playlist.count - 1)
        {
            return FileControls.shared.playlist[currentIndex + 1].name
        }
        return FileControls.shared.playlist[currentIndex].name
    }
    
    func getPrevTrackTitle() -> String {
        if(audioPlayer.currentTime < 5.0 && currentIndex > 0)
        {
            return FileControls.shared.playlist[currentIndex-1].name
        }
        return FileControls.shared.playlist[currentIndex].name
    }
    
    func setupNotificationView(song: Song){
        nowPlayingInfo = [String: Any]()
        
        let playerItem = AVPlayerItem(url: song.url)
        var metadataList = playerItem.asset.metadata as! [AVMetadataItem]
        if(metadataList.isEmpty){
            metadataList = playerItem.asset.commonMetadata
        }
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = song.name
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = song.album
        nowPlayingInfo[MPMediaItemPropertyArtist] = song.artist
        
        
        for item in metadataList {
            guard let key = item.commonKey?.rawValue, let value = item.value else{
                continue
            }
           switch key {
           case "artwork" :
               print("roryclear \(value)")
               let image = UIImage(data: value as! Data)
               let artwork = MPMediaItemArtwork.init(boundsSize: image!.size, requestHandler: { (size) -> UIImage in
                   return image!
               })
               nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
            default:
              continue
           }
        }
        
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration(for: song.url)
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
}
