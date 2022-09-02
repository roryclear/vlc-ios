//
//  FileControlsiOS.swift
//  VLC-iOS
//
//  Created by Rory Clear on 02/09/2022.
//  Copyright © 2022 VideoLAN. All rights reserved.
//

import Foundation
import WatchConnectivity
    class FileControlsiOS: UICollectionViewController, UISearchBarDelegate, WCSessionDelegate {
        
        static let shared = FileControlsiOS()
        
        var session: WCSession?
        
        @available(iOS 9.3, *)
        func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
            
        }
        
        func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
            print("filetransfer finished? \(fileTransfer.file.fileURL) \(error)")
        }
        
        func sessionDidBecomeInactive(_ session: WCSession) {
            
        }
        
        func sessionDidDeactivate(_ session: WCSession) {
            
        }
    
    func configureWatchKitSesstion() {
      print("roryclear configureWatchKitSesstion ??")
      if WCSession.isSupported() {
        session = WCSession.default
        session?.delegate = self
        session?.activate()
      }
    }
    
        
    func addToWatch(for URLs: [URL]) {
        DispatchQueue.main.async { [self] in
        print("addToWatch mediaCategoryViewController")
        if let validSession = self.session, validSession.isReachable {
            print("roryclear validSession?")
            for url in URLs {
                let fileName = url.lastPathComponent
                let md = ["filename":fileName]
                print("file size is \(url.fileSizeString)")
                session?.sendMessage(md, replyHandler: nil, errorHandler: nil)
                var transfer = session?.transferFile(url, metadata: md)
                session?.sendMessage(md, replyHandler: nil, errorHandler: nil)
                //seeProgress(session: session!)
                if #available(iOS 12.0, *) {  //roryclear remove later?
                    while((transfer?.progress.totalUnitCount)! < 100)
                    {
                        print(transfer?.progress)
                        usleep(100000)
                    }
                    print("transfer finsihed? \(transfer?.progress.totalUnitCount) -> \(transfer?.progress)")
                } else {
                    // Fallback on earlier versions
                }
            }
        }else{
            print("roryclear NOT a validSession")
        }
        }
    }
    
}

extension URL { //roryclear not needed long term, copied from stackoverflow
    var attributes: [FileAttributeKey : Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error)")
        }
        return nil
    }

    var fileSize: UInt64 {
        return attributes?[.size] as? UInt64 ?? UInt64(0)
    }

    var fileSizeString: String {
        return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    }

    var creationDate: Date? {
        return attributes?[.creationDate] as? Date
    }
}
