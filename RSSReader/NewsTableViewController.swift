//
//  NewsTableViewController.swift
//  RSSReader
//
//  Created by Polynin Pavel on 29.05.16.
//  Copyright © 2016 Polynin Pavel. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireRSSParser

class NewsTableViewController: UITableViewController {
    
    //===================================//
    // MARK: - Глобальные переменные для NewsTableViewController
    //===================================//
    
    var urlRSSNews = ["http://lenta.ru/rss", "http://www.f1-world.ru/news/rssexp6.xml"] // Адрес RSS Новостей
    var arrayNews = [RSSItem]() // Массив для парсинга ленты новостей
    
    //===================================//
    // MARK: - IBOutlet связывающие Scene и NewsTableViewController
    //===================================//
    
    //===================================//
    // MARK: - IBAction на нашей Scene
    //===================================//
    
    //-----------------------------------// Метод для теста парсинга
    @IBAction func Refresh(sender: UIBarButtonItem) {
        sortArrayNews() // Метод для сортировки arrayNews по дате новости
        for index in 0..<arrayNews.count {
            print(arrayNews[index].link)
        }
    }
    
    //===================================//
    // MARK: - Методы загружаемые перед или после обновления View Controller
    //===================================//
    
    //-----------------------------------// Метод viewDidLoad срабатывает при загрузке View Scene
    override func viewDidLoad() {
        //------------------ Перенос всех свойств класса этому экземпляру
        super.viewDidLoad()
        
        newsParsing(urlRSSNews) // Метод для парсинга RSS
    }
    
    //===================================//
    // MARK: - Кастомные методы
    //===================================//
    
    //===================================//
    // MARK: - Парсинг RSSNews
    //===================================//
    
    //-----------------------------------// Метод для парсинга RSS
    func newsParsing(url: [String]) {
        for index in url {
            //------------------ Запрос через Alamofire
            Alamofire.request(.GET, index).responseRSS() { (response) -> Void in
                if let feed: RSSFeed = response.result.value {
                    for item in feed.items {
                        self.arrayNews.append(item)
                    }
                }
            }
        }
    }
    
    //-----------------------------------// Метод для сортировки arrayNews по дате новости
    func sortArrayNews() {
        for index in 0..<arrayNews.count {
            if arrayNews[index].pubDate != nil {
                arrayNews.sortInPlace{
                    return $0.pubDate?.timeIntervalSince1970 < $1.pubDate?.timeIntervalSince1970
                }
            }
        }
    }
    
    //===================================//
    // MARK: - Методы для работы и настройки TableView
    //===================================//
    
    //-----------------------------------// Метод возвращает кол-во секций TableView
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 0
    }
    
    //-----------------------------------// Метод возвращает кол-во строк в секции TableView
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 0
    }
    
    //-----------------------------------// Создаем ячейку по идентификатору с indexPath в методе для работы и настройки Cell в TableView
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("NewsCell", forIndexPath: indexPath) as! NewsTableViewCell

        return cell
    }
}
