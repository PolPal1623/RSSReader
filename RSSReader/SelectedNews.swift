//
//  SelectedNewsTableView.swift
//  RSSReader
//
//  Created by Polynin Pavel on 27.06.16.
//  Copyright © 2016 Polynin Pavel. All rights reserved.
//

import UIKit

class SelectedNews: UIViewController {
    
    //===================================//
    // MARK: - Глобальные переменные для SelectedNewsTableView
    //===================================//
    
    var titleNewsText = " " // Заголовок
    var descriptionNewsText = " " // Текст
    var linkNews = "" // Ссылка
    
    //===================================//
    // MARK: - IBOutlet связывающие Scene и SelectedNewsTableView
    //===================================//
    
    @IBOutlet weak var titleNews: UILabel! // Заголовок
    @IBOutlet weak var descriptionNews: UILabel! // Текст
    
    //===================================//
    // MARK: - IBAction на нашей Scene
    //===================================//
    
    //-----------------------------------// Метод открыть новость в браузере
    @IBAction func buttonSafari(sender: AnyObject) {
        if let link = NSURL(string: linkNews) {
        UIApplication.sharedApplication().openURL(link)
        }
    }

    //===================================//
    // MARK: - Методы загружаемые перед или после обновления View Controller
    //===================================//

    //-----------------------------------// Метод viewDidLoad срабатывает при загрузке View Scene
    override func viewDidLoad() {
        super.viewDidLoad()

        titleNews.text = titleNewsText // Отображение заголовка
        descriptionNews.text = descriptionNewsText // Отображение текста
    }
}
