//
//  NewsTableViewCell.swift
//  RSSReader
//
//  Created by Polynin Pavel on 29.05.16.
//  Copyright © 2016 Polynin Pavel. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    
    //===================================//
    // MARK: - IBOutlet связывающие Scene и NewsTableViewCell
    //===================================//
   
    @IBOutlet weak var titleNews: UILabel! // Заголовок
    @IBOutlet weak var textNews: UILabel! // Описание новости
    @IBOutlet weak var dateNews: UILabel! // Дата новости
    
}
