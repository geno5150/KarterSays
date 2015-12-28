//
//  extraStuff.swift
//  KarterSays
//
//  Created by Geno Erickson on 12/15/15.
//  Copyright © 2015 SuctionPeach. All rights reserved.
//

import Foundation
func getDocumentsDirectory() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

class RecordedAudio: NSObject{
    var filePathUrl: NSURL!
    var title: String!
    
    init(filePathUrl: NSURL!, title: String!) {
        self.filePathUrl = filePathUrl
        self.title = title
    }
}