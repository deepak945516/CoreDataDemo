//
//  Note.swift
//  CoreDataDemo
//
//  Created by Deepak Kumar on 06/08/19.
//  Copyright © 2019 Deepak Kumar. All rights reserved.
//

import UIKit

enum NoteKeys: String {
    case img = "img"
    case title = "title"
    case desc = "desc"
    case time = "time"
}
struct Note {
    var img: UIImage?
    var title = ""
    var desc = ""
    var time = 0
    
    init(dict: [String: Any?]) {
        img = dict[NoteKeys.img.rawValue] as? UIImage
        title = dict[NoteKeys.title.rawValue] as? String ?? ""
        desc = dict[NoteKeys.desc.rawValue] as? String ?? ""
        time = dict[NoteKeys.time.rawValue] as? Int ?? 0
    }
}
