//
//  DataManager.swift
//  Challenge
//
//  Created by Cainã Souza on 9/4/14.
//  Copyright (c) 2014 Caina Souza. All rights reserved.
//

import UIKit
import CoreData

private let _sharedInstance = DataManager()

extension NSDate
    {
    convenience
    init(dateString:String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "MM/dd/yyyy"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let date: NSDate? = dateStringFormatter.dateFromString(dateString)
        self.init(timeInterval:0, sinceDate:date!)
    }
}

class DataManager: NSObject {
    
    class var sharedInstance : DataManager {
        return _sharedInstance
    }
    
    func addArticle(articleDict: NSDictionary)
    {
        var managedObjectContext: NSManagedObjectContext?
        
        if let app = UIApplication.sharedApplication().delegate as? AppDelegate {
            managedObjectContext = app.managedObjectContext!
            
            if let moc = managedObjectContext {
                
                var article: Article = NSEntityDescription.insertNewObjectForEntityForName("Article", inManagedObjectContext: moc) as Article
                
                article.title = articleDict["title"] as String
                article.authors = articleDict["authors"] as String
                article.website = articleDict["website"] as String
                article.date = NSDate(dateString: articleDict["date"] as String)
                
                var error: NSError? = nil
                if moc.hasChanges && !moc.save(&error) {
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                }
            }
        }
    }
    
    func getAllArticles() -> NSArray?
    {
        var managedObjectContext: NSManagedObjectContext?
        
        if let app = UIApplication.sharedApplication().delegate as? AppDelegate {
            managedObjectContext = app.managedObjectContext!
            
            if let moc = managedObjectContext {
                var fetchRequest: NSFetchRequest = NSFetchRequest()
                
                var entity = NSEntityDescription.entityForName("Article", inManagedObjectContext:moc)
                fetchRequest.entity = entity
                
                var error: NSError? = nil
                let fetchedRecords: NSArray = moc.executeFetchRequest(fetchRequest, error:&error)!
                
                return fetchedRecords
            }
        }
        return nil
    }
    
    func deleteAllArticles()
    {
        var managedObjectContext: NSManagedObjectContext?
        
        if let app = UIApplication.sharedApplication().delegate as? AppDelegate {
            managedObjectContext = app.managedObjectContext!
            
            if let moc = managedObjectContext {
                
                let articlesArray = getAllArticles()!
                
                for article in articlesArray {
                    moc.deleteObject(article as Article)
                }
                
                var error: NSError? = nil
                if moc.hasChanges && !moc.save(&error) {
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                }
            }
        }
    }
}