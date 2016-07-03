//
//  AddCannelTableViewController.swift
//  RSSReader
//
//  Created by Polynin Pavel on 29.06.16.
//  Copyright © 2016 Polynin Pavel. All rights reserved.
//

import UIKit
import RealmSwift

class AddChannelTableViewController: UITableViewController {
    
    //===================================//
    // MARK: - Глобальные переменные для SelectedNewsTableView
    //===================================//
    
    //===================================//
    // MARK: - IBOutlet связывающие Scene и SelectedNewsTableView
    //===================================//
    
    //===================================//
    // MARK: - IBAction на нашей Scene
    //===================================//
    
    //===================================//
    // MARK: - Кастомные методы
    //===================================//
    
    //-----------------------------------// Метод для исправления самых распространенных ошибок при вводе адреса канала
    func changeMistakeURLName(urlString: String) -> String {
        var urlNotSpaceString = "" // Адрес без пробелов
        for index in urlString.characters {
            if index != " " {
                urlNotSpaceString = urlNotSpaceString + String(index)
            }
        }
        return urlNotSpaceString
    }
    
    //-----------------------------------// Метод для проверки на ошибки в адресе канала
    func errorURLName(urlString: String) -> Bool {
        
        var firstInspection = "" // Проверка начала введенного адреса
        var endInspection = "" // Проверка окончания введенного адреса
        let firstOne = "http://" // Правильное начало адреса
        let firstTwo = "https:/" // Правильное начало адреса
        let endOne = "ssr" // Правильное окончание адреса вариант 1
        let endTwo = "lmx" // Правильное окончание адреса вариант 2
        var firstTrue = false // Совпадение начала адреса
        var endTrue = false // Совпадение окончания адреса
        
        var i = 1 // Счетчик
        // Проверка начала введенного адреса
        for index in urlString.characters {
            if i <= 7 {
                firstInspection = firstInspection + String(index)
                i += 1
            } else {
                break
            }
        }
        if firstOne == firstInspection || firstTwo == firstInspection{
            firstTrue = true
        }
        // Проверка окончания введенного адреса
        i = 1 // Обнуление счетчика
        for index in urlString.characters.reverse() {
            if i <= 3 {
                endInspection = endInspection + String(index)
                i += 1
            } else {
                break
            }
        }
        if endOne == endInspection || endTwo == endInspection {
            endTrue = true
        }
        return firstTrue && endTrue
    }
    
    //-----------------------------------// Метод для сохранения какала
    func saveChannel(name: String, link: String) {
        let realm = try! Realm() // Точка входа в Realm
        let saveChannel = SavedChannel()
        saveChannel.nameCannel = name
        saveChannel.linkCannel = link
        try! realm.write {realm.add(saveChannel)}
        self.tableView.reloadData() // Метод для перезагрузки таблицы
    }
   
    //-----------------------------------// Метод для создания alertController для добавления каналов
    func addChannel(nameAddChannel: String?, linkAddChannel: String?) {
        //-----------------------------------// Создание alertController
        let alertController = UIAlertController(title: "Add new rss channel", message: "Create name channel and copy url link channel", preferredStyle: .Alert)
        //-----------------------------------// Добавление textField
        alertController.addTextFieldWithConfigurationHandler { (UItextField) in
            UItextField.placeholder = "Name channel"
            // Проверка на наличие имени при вызове метода addChannel
            if let textName = nameAddChannel {
                UItextField.text = textName
            }
        }
        alertController.addTextFieldWithConfigurationHandler { (UItextField) in
            UItextField.placeholder = "URL link channel"
            // Проверка на наличие URL при вызове метода addChannel
            if let textURL = linkAddChannel {
                UItextField.text = textURL
            }
        }
        //-----------------------------------// Добавление действий
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in }
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (action) in
            
            if let nameCannel = alertController.textFields?[0].text, linkChannel = alertController.textFields?[1].text {
                // Проверка на наличие имени канала и обработка ошибки
                if nameCannel.characters.count > 0 {
                    // Проверка на ошибки в адресе канала и обработка ошибки
                    let linkChannel = self.changeMistakeURLName(linkChannel)
                    if self.errorURLName(linkChannel) {
                        
                        self.saveChannel(nameCannel, link: linkChannel) // Метод для сохранения какала
                        
                        // Обработка ошибки адреса канала
                    } else {
                        let alertErrorURLController = UIAlertController(title: "You have mistake in URLChannel", message: "must be: http:// ... rss or http:// ... xml", preferredStyle: .ActionSheet)
                        let backAction = UIAlertAction(title: "Back", style: .Cancel) { (action) in
                            self.addChannel(nameCannel, linkAddChannel: linkChannel)
                        }
                        alertErrorURLController.addAction(backAction)
                        self.presentViewController(alertErrorURLController, animated: true, completion: nil)
                    }
                    // Обработка ошибки имени канала
                } else {
                    let alertErrorNameController = UIAlertController(title: "You must create name for channel", message: "tap back", preferredStyle: .ActionSheet)
                    let backAction = UIAlertAction(title: "Back", style: .Cancel) { (action) in
                        self.addChannel("", linkAddChannel: linkChannel)
                    }
                    alertErrorNameController.addAction(backAction)
                    self.presentViewController(alertErrorNameController, animated: true, completion: nil)
                }
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //-----------------------------------// Метод для перехода в alertController
    func pressedButtonAdd() {
        addChannel(nil, linkAddChannel: nil)
    }
    
    //-----------------------------------// Метод для создания кнопки справа на Navigation Bar
    func createBarButton() {
        let rightButton : UIBarButtonItem = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(AddChannelTableViewController.pressedButtonAdd))
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    //===================================//
    // MARK: - Методы загружаемые перед или после обновления View Controller
    //===================================//
    
    //-----------------------------------// Метод viewDidLoad срабатывает при загрузке View Scene
    override func viewDidLoad() {
        //------------------ Перенос всех свойств класса этому экземпляру
        super.viewDidLoad()
        createBarButton() // Метод для создания кнопки справа на Navigation Bar
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
        let realm = try! Realm() // Точка входа в Realm
        let listChannel = realm.objects(SavedChannel) // Извлечение канала из Realm
        return listChannel.count
    }
    
    //-----------------------------------// Создаем ячейку по идентификатору с indexPath в методе для работы и настройки Cell в TableView
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let realm = try! Realm() // Точка входа в Realm
        let listChannel = realm.objects(SavedChannel) // Извлечение канала из Realm
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! AddChannelTableViewCell
        cell.linkString.text = listChannel[indexPath.row].nameCannel

        return cell
    }
    
    //-----------------------------------// Метод для работы с действиями по свайпу ячейки
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        //------------------ Действие: продукт в корзине покупок. Кнопка на весь экран
        let delete = UITableViewRowAction(style: .Default, title: "Delete") {(action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            let realm = try! Realm() // Точка входа в Realm
            let listChannel = realm.objects(SavedChannel) // Извлечение канала из Realm
            let channel = listChannel[indexPath.row] // Объект в выбранной ячейке для его удаления
            //------------------ Удаление через Realm
            try! realm.write { realm.delete(channel) }
            self.tableView.reloadData() // Метод для перезагрузки таблицы
        }
        return [delete]
    }
    
    //-----------------------------------// Метод определяющий действия при нажатии на ячейку
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true) // Убирает анимацию залипания при нажатия(выбора ячейки)
        
    }
}
