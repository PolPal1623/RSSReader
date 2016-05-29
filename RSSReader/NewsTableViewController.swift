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
    
    //===================================//
    // MARK: - IBOutlet связывающие Scene и NewsTableViewController
    //===================================//
    
    //===================================//
    // MARK: - IBAction на нашей Scene
    //===================================//
    
    //===================================//
    // MARK: - Методы загружаемые перед или после обновления View Controller
    //===================================//
    
    //-----------------------------------// Метод viewDidLoad срабатывает при загрузке View Scene
    override func viewDidLoad() {
        //------------------ Перенос всех свойств класса этому экземпляру
        super.viewDidLoad()
    }
    
    //===================================//
    // MARK: - Кастомные методы
    //===================================//
    
    //===================================//
    // MARK: - Парсинг RSSNews
    //===================================//
    
    
    
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
