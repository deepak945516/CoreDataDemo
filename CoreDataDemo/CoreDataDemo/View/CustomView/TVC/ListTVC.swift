//
//  ListTVC.swift
//  CoreDataDemo
//
//  Created by Deepak Kumar on 05/08/19.
//  Copyright © 2019 Deepak Kumar. All rights reserved.
//

import UIKit

final class ListTVC: UITableViewCell {
    // MARK: - Properties
    @IBOutlet private weak var imgView: UIImageView!
    @IBOutlet private weak var lblTitle: UILabel!
    @IBOutlet private weak var lblSubtitle: UILabel!
    
    // MARK: - Life Cycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        imgView.layer.cornerRadius = imgView.frame.size.height / 2
    }
    
    func configure(note: Note) {
        imgView.image = note.img
        lblTitle.text = note.title
        lblSubtitle.text = note.desc
    }
}
