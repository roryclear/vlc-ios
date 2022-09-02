//
//  FileControls.swift
//  VLC-watchOS WatchKit Extension
//
//  Created by Rory Clear on 02/09/2022.
//  Copyright © 2022 VideoLAN. All rights reserved.
//

import WatchKit
import WatchConnectivity
import Foundation
import MediaPlayer

class FileControls: NSObject, WCSessionDelegate {
    var playlist: [Song] = []
    
    static let shared = FileControls()
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    
    let session = WCSession.default
    
    override init() {
        print("roryclear init???")
    //    session.activate()
    }
    
    
    func connectToPhone() {
        session.delegate = self
        session.activate()
    }
    
    func printSomething() {
        session.delegate = self
        session.activate()
        print("ffs roryclear")
        if session.isReachable {
            print("session is reachable")
        }else {
            print("session is NOT reachable")
        }
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) { //roryclear delete later
      print("received data: \(message)")
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        do {
            let receivedData = try Data(contentsOf: file.fileURL)
            let receivedMetaData = file.metadata
            let fileName = receivedMetaData!["filename"] as! String
            print("file name is \(fileName)")
            let path = FileManager.default.urls(for: .documentDirectory,
                                                   in: .userDomainMask)[0].appendingPathComponent(fileName) //roryclear fix later
            try? receivedData.write(to: path)
            print("roryclear data received count -> \(receivedData.count)")
            
                
        } catch {
            print("error reading file -> \(error)")
        }
    }
    
    func getAllMp3s() -> [Song] { //roryclear change to proper datastructure with title?
        var out: [Song] = []
        print("roryclear getallmp3s???")
        let documentsUrl0 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl0,
                                                                       includingPropertiesForKeys: nil,
                                                                    options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                if fileURL.pathExtension == "mp3" {
                    var thisName: String = "Unknown" //roryclear this is shit
                    var thisArist: String = "Unknown"
                    var thisAlbum: String = "Unknown"
                    print("found file at ", fileURL)
                    let playerItem = AVPlayerItem(url: fileURL)
                    var metadataList = playerItem.asset.metadata
                    if metadataList.isEmpty {
                        metadataList = playerItem.asset.commonMetadata
                    }
                    print("roryclear metadata list = \(metadataList)")
                    for item in metadataList {
                        guard let key = item.commonKey?.rawValue, let value = item.value else {
                            continue
                        }
                       switch key {
                       case "title" :
                           thisName = value as! String
                       case "artist" :
                           thisArist = value as! String
                       case "albumName" :
                           thisAlbum = value as! String
                        //case "artist": artistLabel.text = value as? String
                        //case "artwork" where value is Data : artistImage.image = UIImage(data: value as! Data)
                        default:
                          continue
                       }
                    }
                    out.append(Song(name: thisName, artist: thisArist, album: thisAlbum, url: fileURL, number: 0))
                }
            }
        } catch { print(error) }
        let outSorted = out.sorted {
            $0.name.lowercased() < $1.name.lowercased()
        }
        FileControls.shared.playlist = outSorted
        return outSorted
    }
    
    func getAllMp3s(album: String) -> [Song] { //roryclear change to proper datastructure with title? //this is bad again
        var out: [Song] = []
        print("roryclear getallmp3s???")
        let documentsUrl0 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl0,
                                                                       includingPropertiesForKeys: nil,
                                                                    options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                if fileURL.pathExtension == "mp3" {
                    var thisName: String = "Unknown" //roryclear this is shit
                    var thisArist: String = "Unknown"
                    var thisAlbum: String = "Unknown"
                    var thisNumber: Int = 0
                    print("found file at ", fileURL)
                    let playerItem = AVPlayerItem(url: fileURL)
                    var metadataList = playerItem.asset.metadata
                    if metadataList.isEmpty {
                        metadataList = playerItem.asset.commonMetadata
                    }
                    for item in metadataList {
                        guard let key = item.commonKey?.rawValue, let value = item.value
                        else {
                            guard let key = item.identifier?.rawValue, let value = item.value else {
                                guard let key: String = item.key as? String, let value = item.value else {
                                    continue
                                }
                                switch key {
                                    case "TRK" :
                                    let thisNumberString = value as! String
                                    thisNumber = Int(thisNumberString.components(separatedBy: "/")[0]) ?? 0
                                default:
                                    continue
                                }
                                continue
                            }
                            switch key {
                            case "id3/TRCK" :
                                let thisNumberString = value as! String
                                thisNumber = Int(thisNumberString.components(separatedBy: "/")[0]) ?? 0
                                print("roryclear TRCK???? \(value as! String)")
                             //case "artist": artistLabel.text = value as? String
                             //case "artwork" where value is Data : artistImage.image = UIImage(data: value as! Data)
                             default:
                               continue
                            }
                            continue
                        }
                        
                       switch key {
                       case "title" :
                           thisName = value as! String
                       case "artist" :
                           thisArist = value as! String
                       case "albumName" :
                           thisAlbum = value as! String
                        //case "artist": artistLabel.text = value as? String
                        //case "artwork" where value is Data : artistImage.image = UIImage(data: value as! Data)
                        default:
                          continue
                       }
                    }
                    
                    if thisAlbum == album {
                    out.append(Song(name: thisName, artist: thisArist, album: thisAlbum, url: fileURL, number: thisNumber))
                    }
                }
            }
        } catch { print(error) }
        let outSorted = out.sorted {
            $0.number < $1.number
        }
        FileControls.shared.playlist = outSorted
        return outSorted
    }
    
    func getAllMp3sForArtist(artist: String) -> [Song] { //roryclear change to proper datastructure with title? //this is bad again
        var out: [Song] = []
        print("roryclear getallmp3s???")
        let documentsUrl0 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl0,
                                                                       includingPropertiesForKeys: nil,
                                                                    options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                if fileURL.pathExtension == "mp3" {
                    var thisName: String = "Unknown" //roryclear this is shit
                    var thisArist: String = "Unknown"
                    var thisAlbum: String = "Unknown"
                    let thisNumber: Int = 0
                    print("found file at ", fileURL)
                    let playerItem = AVPlayerItem(url: fileURL)
                    var metadataList = playerItem.asset.metadata
                    if metadataList.isEmpty {
                        metadataList = playerItem.asset.commonMetadata
                    }
                    for item in metadataList {
                        guard let key = item.commonKey?.rawValue, let value = item.value else {
                            continue
                        }
                        
                       switch key {
                       case "title" : thisName = value as! String
                       case "artist" : thisArist = value as! String
                       case "albumName" : thisAlbum = value as! String
                        default:
                          continue
                       }
                    }
                    if thisArist == artist {
                    out.append(Song(name: thisName, artist: thisArist, album: thisAlbum, url: fileURL, number: thisNumber))
                    }
                }
            }
        } catch { print(error) }
        let outSorted = out.sorted {
            $0.name.lowercased() < $1.name.lowercased()
        }
        FileControls.shared.playlist = outSorted
        return outSorted
    }
    
    func getAllArtists() -> [Artist] { //roryclear change to proper datastructure with title?
        var artists: [String] = []
        var out: [Artist] = []
        print("rorylcear getallmp3s???")
        let documentsUrl0 =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl0,
                                                                       includingPropertiesForKeys: nil,
                                                                    options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                if fileURL.pathExtension == "mp3" {
                    print("found file at ",fileURL)
                    let playerItem = AVPlayerItem(url: fileURL)
                    var metadataList = playerItem.asset.metadata as! [AVMetadataItem]
                    if(metadataList.isEmpty){
                        metadataList = playerItem.asset.commonMetadata
                    }
                    for item in metadataList {
                        guard let key = item.commonKey?.rawValue, let value = item.value else{
                            continue
                        }

                       switch key {
                       case "artist" :
                           if(!artists.contains(value as! String)) //roryclear this is bad
                           {
                               out.append(Artist(name: value as! String))
                               artists.append(value as! String)
                           }
                        default:
                          continue
                       }
                    }
                }
            }
        } catch  { print(error) }
        let outSorted = out.sorted {
            $0.name < $1.name
        }
        return outSorted
    }
    
    func getAllAlbums() -> [Album]  { //roryclear change to proper datastructure with title?
        var albums: [String] = []
        var out: [Album] = []
        print("rorylcear getallmp3s???")
        let documentsUrl0 =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl0,
                                                                       includingPropertiesForKeys: nil,
                                                                    options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                if fileURL.pathExtension == "mp3" {
                    print("found file at ",fileURL)
                    var albumNameFound = false
                    var artworkFound = false
                    var newAlbumFound = false
                    var artistFound = false
                    let playerItem = AVPlayerItem(url: fileURL)
                    var thisAlbumName = ""
                    var thisArtist = ""
                    var thisArtwork = UIImage()
                    var metadataList = playerItem.asset.metadata as! [AVMetadataItem]
                    if(metadataList.isEmpty){
                        metadataList = playerItem.asset.commonMetadata
                    }
                    for item in metadataList {
                        guard let key = item.commonKey?.rawValue, let value = item.value else{
                            continue
                        }

                       switch key {
                       case "albumName" :
                           albumNameFound = true
                           if(!albums.contains(value as! String)) //roryclear this is bad
                           {
                               newAlbumFound = true
                               thisAlbumName = value as! String
                               //out.append(Album(name: value as! String))
                               albums.append(value as! String)
                           }else{
                               break
                           }
                           if(artworkFound && artistFound){
                               break
                           }
                       case "artwork" :
                           artworkFound = true
                           thisArtwork = UIImage(data: value as! Data)!
                           if(albumNameFound && artistFound){
                               break
                           }
                       case "artist" :
                           artistFound = true
                           thisArtist = value as! String
                           if(albumNameFound && artworkFound) {
                               break
                           }
                        //case "artist": artistLabel.text = value as? String
                        //case "artwork" where value is Data : artistImage.image = UIImage(data: value as! Data)
                        default:
                          continue
                       }
                    }
                    if(newAlbumFound)
                    {
                        if(thisArtwork == UIImage())
                        {
                            print("roryclear no artwork for \(thisAlbumName)")
                            thisArtwork = UIImage(named: "album-placeholder-dark")!
                        }
                        out.append(Album(name: thisAlbumName, artist: thisArtist, artwork: thisArtwork))
                    }
                }
            }
        } catch  { print(error) }
        let outSorted = out.sorted {
            $0.name.lowercased() < $1.name.lowercased()
        }
        return outSorted
    }
    
    func  deleteSong(song: Song) {
        print("deleting song \(song.name)")
        
        var index = 0
        for s in playlist {   //roryclear this could be quicker? pass in index?
            if song.url == s.url {
                playlist.remove(at: index)

            }
            index += 1
        }
         
        
        do {
            print("roryclear deleting file at ", song.url)
            try FileManager.default.removeItem(at: song.url)
            return
        } catch { print(error) }
    }
    
    func deleteAllMp3s() { //RORYCLEAR DELETE LATER
        print("rorylcear deleteallmp3s???")
        let documentsUrl0 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl0,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                if fileURL.pathExtension == "mp3" {
                    print("roryclear deleting file at ", fileURL)
                    try FileManager.default.removeItem(at: fileURL)
                }
            }
        } catch { print(error) }
    }
    
}
