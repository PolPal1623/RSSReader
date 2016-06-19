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
import RealmSwift

class SavedNews: Object {
    dynamic var title = ""
    dynamic var itemDescription = ""
    dynamic var link = ""
    dynamic var pubDate: NSDate? = nil
}

class NewsTableViewController: UITableViewController {
    
    //===================================//
    // MARK: - Глобальные переменные для NewsTableViewController
    //===================================//
    
    var urlRSSNews = ["http://lenta.ru/rss"] // Адрес RSS Новостей
    var arrayNews = [RSSItem]() // Массив для парсинга ленты новостей
    var listNews: Results<(SavedNews)>! // Массив сохраненных новостей из библиотеки
    
    //===================================//
    // MARK: - IBOutlet связывающие Scene и NewsTableViewController
    //===================================//
    
    //===================================//
    // MARK: - IBAction на нашей Scene
    //===================================//
    
    //-----------------------------------// Метод для теста парсинга
    @IBAction func Refresh(sender: UIBarButtonItem) {
        refreshSomething() // Метод для обновления запроса URL и перезагрузки таблицы
        
        // Задержка для подгрузки новостей
        delayClosure(4) {
            if self.arrayNews.count != 0 {
                print("Save")
                self.saveNewsInRealm() // Метод для сохранения новостей
            } else {
                print("Extract")
                self.extractNewsInRealm() // Метод для извлечения новостей при отсутствии интернета
            }
        }
    }
    
    //===================================//
    // MARK: - Методы загружаемые перед или после обновления View Controller
    //===================================//
    
    //-----------------------------------// Метод viewDidLoad срабатывает при загрузке View Scene
    override func viewDidLoad() {
        //------------------ Перенос всех свойств класса этому экземпляру
        super.viewDidLoad()
        
        refreshSomething() // Метод для обновления запроса URL и перезагрузки таблицы
        
        // Задержка для подгрузки новостей
        delayClosure(4) {
            if self.arrayNews.count != 0 {
                print("Save")
                self.saveNewsInRealm() // Метод для сохранения новостей
            } else {
                print("Extract")
                self.extractNewsInRealm() // Метод для извлечения новостей при отсутствии интернета
            }
        }
    }
    
    //===================================//
    // MARK: - Кастомные методы
    //===================================//
    
    //-----------------------------------// Метод для задержки вызова функции
    func delayClosure(delay: Double, closure: () -> ()) {
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))),
            dispatch_get_main_queue(), closure)
    }
    
    //-----------------------------------// Метод для обновления запроса URL и перезагрузки таблицы
    func refreshSomething() {
        newsParsing(self.urlRSSNews) // Метод для парсинга RSS
        // Задержка для завершения парсинга
        delayClosure(1) {
            self.sortArrayNews() // Метод для сортировки arrayNews по дате новости
            self.tableView.reloadData() // Перезагрузка таблицы
        }
    }
    
    //-----------------------------------// Метод для сохранения/обновления новостей
    func saveNewsInRealm() {
        let realm = try! Realm() // Точка входа в Realm
       
        // Удаление всех новостей перед сохранением нового блока
        try! realm.write {
            realm.deleteAll()
        }
        
        //Сохранение новостей в Realm
        for optionalNews in arrayNews {
            if optionalNews.title != nil && optionalNews.itemDescription != nil && optionalNews.link != nil && optionalNews.pubDate != nil  {
                    let newsRealm = SavedNews()
                    newsRealm.title = optionalNews.title!
                    newsRealm.itemDescription = optionalNews.itemDescription!
                    newsRealm.link = optionalNews.link!
                    newsRealm.pubDate = optionalNews.pubDate
                    try! realm.write {realm.add(newsRealm)}
            }
        }
    }
    
    //-----------------------------------// Метод для извлечения новостей
    func extractNewsInRealm() {
        let realm = try! Realm() // Точка входа в Realm
        listNews = realm.objects(SavedNews) // Извлечение новостей из Realm
        self.tableView.reloadData() // Перезагрузка таблицы
    }
    
    //-----------------------------------// Метод для перевода даты в читаемый вид
    func upgrateDate(difficultDate: NSDate?) -> String {
        let liteData = difficultDate!
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year, .Hour, .Minute], fromDate: liteData)
        let hour = components.hour
        let minuteInt = components.minute
        var minute = "00"
        if minuteInt < 10 {
            minute = "0" + String(minuteInt)
        } else {
            minute = String(minuteInt)
        }
        let day = components.day
        let month = components.month
        let year = components.year
        let date = "\(hour):\(minute) \(day)/\(month)/\(year)"
        return date
    }
    
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
                    return $0.pubDate?.timeIntervalSince1970 > $1.pubDate?.timeIntervalSince1970 // Сортировка по дате публикации
                }
            }
        }
    }
    
    //===================================//
    // MARK: - Методы для работы и настройки TableView
    //===================================//
    
    //-----------------------------------// Метод возвращает кол-во секций TableView
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //-----------------------------------// Метод возвращает кол-во строк в секции TableView
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Выбор массива для отображения в таблице
        if arrayNews.count == 0 {
            let realm = try! Realm() // Точка входа в Realm
            listNews = realm.objects(SavedNews) // Извлечение новостей из Realm
            return listNews.count
        } else {
            return arrayNews.count
        }
    }
    
    //-----------------------------------// Создаем ячейку по идентификатору с indexPath в методе для работы и настройки Cell в TableView
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("NewsCell", forIndexPath: indexPath) as! NewsTableViewCell
        
        // Выбор массива для отображения в таблице
        if arrayNews.count == 0 {
            cell.titleNews.text = listNews[indexPath.row].title // Заголовок
            cell.textNews.text = listNews[indexPath.row].itemDescription // Краткое описание новости
            let date = upgrateDate(listNews[indexPath.row].pubDate) // Дата
            cell.dateNews.text = date
        } else {
            cell.titleNews.text = arrayNews[indexPath.row].title // Заголовок
            cell.textNews.text = arrayNews[indexPath.row].itemDescription // Краткое описание новости
            let date = upgrateDate(arrayNews[indexPath.row].pubDate) // Дата
            cell.dateNews.text = date
        }
        return cell
    }
    
    //-----------------------------------// Действия по нажатию на конкретную ячейку
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("cell \(indexPath.row)")
    }
}







