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

class SavedChannel: Object {
    dynamic var nameCannel = ""
    dynamic var linkCannel = ""
}

class NewsTableViewController: UITableViewController {
    
    //===================================//
    // MARK: - Глобальные переменные для NewsTableViewController
    //===================================//
    
    var urlRSSNews = [String]() // Адрес RSS Новостей
    var arrayNews = [RSSItem]() // Массив для парсинга ленты новостей
    var listNews: Results<(SavedNews)>! // Массив сохраненных новостей из библиотеки
    var listChannel: Results<(SavedChannel)>! // Массив сохраненных каналов
    let timeForRefresh: UInt32 = 2 // Время на загрузку новостей
   
    //===================================//
    // MARK: - IBAction на нашей Scene
    //===================================//
    
    //-----------------------------------// Метод для перехода на AddChannelTableViewController
    @IBAction func buttonAddCannel(sender: AnyObject) {
        let viewController = storyboard?.instantiateViewControllerWithIdentifier("addCannel") as! AddChannelTableViewController // Инициализация VC для перехода
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    //===================================//
    // MARK: - Парсинг RSSNews
    //===================================//
    
    //-----------------------------------// Метод для парсинга RSS
    func newsParsing(url: [String]) {
        // Удаление старого массива новостей перед добавлением нового блока
        if arrayNews.count > 0 {
            arrayNews.removeAll()
        }
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
    // MARK: - Кастомные методы
    //===================================//
   
    //-----------------------------------// Метод для действий при первом запуске
    func firstLaunch() {
        let launchedBefore = NSUserDefaults.standardUserDefaults().boolForKey("launchedBefore")
        if !launchedBefore  {
            let realm = try! Realm() // Точка входа в Realm
            let firstChannel = SavedChannel()
            firstChannel.nameCannel = "Lenta.ru"
            firstChannel.linkCannel = "http://lenta.ru/rss"
            try! realm.write {realm.add(firstChannel)}
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "launchedBefore")
        }
    }
    
    //-----------------------------------// Метод для обновления списка каналов
    func updateListChannel() {
        let realm = try! Realm() // Точка входа в Realm
        listChannel = realm.objects(SavedChannel) // Извлечение каналов из Realm
        urlRSSNews.removeAll()
        for index in listChannel {
            urlRSSNews.append(index.linkCannel)
        }
    }
    
     //-----------------------------------// Метод для обновления блока новостей
    func refresh() {
        refreshSomething()
        sleep(timeForRefresh)
        refreshControl!.endRefreshing()
    }
    
    //-----------------------------------// Метод для задержки вызова функции
    func delayClosure(delay: UInt32, closure: () -> ()) {
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, Int64(Double(delay) * Double(NSEC_PER_SEC))),
            dispatch_get_main_queue(), closure)
    }
    
    //-----------------------------------// Метод для сохранения/обновления новостей в кэше
    func saveNewsInRealm() {
        // Удаление всех новостей перед сохранением нового блока
        let realm = try! Realm() // Точка входа в Realm
        listNews = realm.objects(SavedNews)
        try! realm.write {
            realm.delete(listNews)
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
    
    //-----------------------------------// Метод для извлечения новостей из памяти
    func extractNewsInRealm() {
        let realm = try! Realm() // Точка входа в Realm
        listNews = realm.objects(SavedNews) // Извлечение новостей из Realm
        self.tableView.reloadData() // Перезагрузка таблицы
    }
    
    //-----------------------------------// Метод для обновления запроса по URL и сохранения нового блока в кэш
    func refreshSomething() {
        updateListChannel()
        newsParsing(self.urlRSSNews) // Метод для парсинга RSS
        // Задержка для завершения парсинга
        delayClosure(timeForRefresh) {
            self.sortArrayNews() // Метод для сортировки arrayNews по дате новости
            self.tableView.reloadData() // Перезагрузка таблицы
        }
        // Задержка для подгрузки новостей из кэша
        delayClosure(timeForRefresh*2) {
            if self.arrayNews.count != 0 {
                self.saveNewsInRealm() // Метод для сохранения новостей
                print("update news cashe")
            } else {
                let realm = try! Realm() // Точка входа в Realm
                self.listChannel = realm.objects(SavedChannel) // Извлечение каналов из Realm
                if self.listChannel.count != 0 {
                    let alertController = UIAlertController(title: "No Internet", message: "News will download from the cache, if you have already included the application", preferredStyle: .ActionSheet)
                    let okAction = UIAlertAction(title: "Ok", style: .Cancel) { (action) in
                        self.extractNewsInRealm() // Метод для извлечения новостей при отсутствии интернета
                    }
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: "Mistake", message: "You don't have channel", preferredStyle: .ActionSheet)
                    let okAction = UIAlertAction(title: "Ok", style: .Cancel) { (action) in
                        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("addCannel") as! AddChannelTableViewController // Инициализация VC для перехода
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    //-----------------------------------// Метод для перевода даты в читаемый вид
    func upgrateDate(difficultDate: NSDate?) -> String {
        // Проверка на наличие даты
        if let liteData = difficultDate {
            let calendar = NSCalendar.currentCalendar() // Обращение к календарю
            let components = calendar.components([.Day , .Month , .Year, .Hour, .Minute], fromDate: liteData) // Выделения компонентов из календаря
            let hour = components.hour
            let minuteInt = components.minute
            var minute = "00"
            // Условия для корректного отображения минут со значениями меньше 10
            if minuteInt < 10 {
                minute = "0" + String(minuteInt)
            } else {
                minute = String(minuteInt)
            }
            let day = components.day
            let month = components.month
            let year = components.year
            let date = "\(hour):\(minute) \(day)/\(month)/\(year)" // Компановка даты
            return date
        } else {
            return "non date"
        }
    }
    
    //===================================//
    // MARK: - Методы загружаемые перед или после обновления View Controller
    //===================================//
    
    //-----------------------------------// Метод viewDidLoad срабатывает при загрузке View Scene
    override func viewDidLoad() {
        //------------------ Перенос всех свойств класса этому экземпляру
        super.viewDidLoad()
        
        firstLaunch() // Первый запуск
        refreshSomething() // Метод для обновления запроса URL и перезагрузки таблицы
        
        // Метод для обновления блока новостей
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(NewsTableViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
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
        // Выбор массива для отображения в таблице (проверка на наличие успешного соединения с интернетом)
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
        let viewController = storyboard?.instantiateViewControllerWithIdentifier("SelectedNews") as! SelectedNews // Инициализация VC для перехода
        // Выбор массива для отображения в таблице (проверка на наличие успешного соединения с сервером)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true) // Убирает анимацию залипания при нажатии (выборе ячейки)
        
        // Выбор массива для отображения в таблице (проверка на наличие успешного соединения с интернетом)
        if arrayNews.count == 0 {
                viewController.titleNewsText = listNews[indexPath.row].title
                viewController.descriptionNewsText = listNews[indexPath.row].itemDescription
                viewController.linkNews = listNews[indexPath.row].link
        } else {
            if let titleNewsText = arrayNews[indexPath.row].title {
                viewController.titleNewsText = titleNewsText
            }
            if let descriptionNewsText = arrayNews[indexPath.row].itemDescription {
                viewController.descriptionNewsText = descriptionNewsText
            }
            if let linkNews = arrayNews[indexPath.row].link {
                viewController.linkNews = linkNews
            }
        }
        self.navigationController?.pushViewController(viewController, animated: true) // Переход на другой VC
    }
}