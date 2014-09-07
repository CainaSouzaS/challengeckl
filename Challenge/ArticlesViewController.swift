//
//  ArticlesViewController.swift
//  Challenge
//
//  Created by Cainã Souza on 9/4/14.
//  Copyright (c) 2014 Caina Souza. All rights reserved.
//

import UIKit
import QuartzCore

extension NSDate
    {
    func formatDate() -> String {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "dd/MM/yyyy"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let dateString: String = dateStringFormatter.stringFromDate(self)
        
        return dateString
    }
}

class ArticlesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate {
    
    let dataManager = DataManager.sharedInstance
    var articlesArray: NSArray? = nil
    @IBOutlet var tableView: UITableView?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named:"NavBarBg").resizableImageWithCapInsets(UIEdgeInsetsMake(1, 1, 10, 1)), forBarMetrics: .Default)
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "LogoNavBar"))
        
        self.articlesArray = dataManager.getAllArticles()!
        self.tableView!.reloadData()
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let url = NSURL(string:"http://ckl.io/challenge/")
        var session = NSURLSession.sharedSession()
        
        var task:NSURLSessionDataTask = session.dataTaskWithURL(url, completionHandler: {
            (data: NSData!, response: NSURLResponse!, error: NSError!) in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if error != nil {
                println("API error: \(error), \(error.userInfo)")
                
                let alert = UIAlertView()
                alert.title = "Error"
                alert.message = error.localizedDescription
                alert.addButtonWithTitle("OK")
                alert.show()
            }
            
            if (response != nil) {
                var jsonError: NSError?
                var articlesJson: NSArray = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as NSArray
                
                if jsonError != nil {
                    println("Error parsing json: \(jsonError)")
                }else {
                    println("Articles json: \(articlesJson)")
                    
                    // Deleting all articles stored before to replace with the new ones
                    self.dataManager.deleteAllArticles()
                    
                    for article in articlesJson {
                        self.dataManager.addArticle(article as NSDictionary)
                    }
                    
                    self.articlesArray = self.dataManager.getAllArticles()!
                    
                    self.tableView!.reloadData()
                    
                    let alert = UIAlertView()
                    alert.title = "Info"
                    alert.message = "Content updated!"
                    alert.addButtonWithTitle("OK")
                    alert.show()
                }
            }else{
                let alert = UIAlertView()
                alert.title = "Error"
                alert.message = "Error to update content. Showing previous articles."
                alert.addButtonWithTitle("OK")
                alert.show()
            }
        })
        
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     * Show action sheet with options to reorder the articles
     */
    @IBAction func showOrderMenu() {
        var orderActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Author", "Date", "Title", "Website")
        orderActionSheet.tintColor = UIColor.grayColor()
        
        orderActionSheet.showInView(self.view)
    }
    
    // Table view methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let articles = self.articlesArray {
            return articles.count
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = self.tableView!.dequeueReusableCellWithIdentifier("ArticleCell") as UITableViewCell
        
        var article = self.articlesArray!.objectAtIndex(indexPath.row) as Article
        
        let titleLabel = cell.viewWithTag(1) as UILabel
        let authorsLabel = cell.viewWithTag(2) as UILabel
        let websiteLabel = cell.viewWithTag(3) as UILabel
        let dateLabel = cell.viewWithTag(4) as UILabel
        dateLabel.layer.masksToBounds = true
        dateLabel.layer.cornerRadius = 4
        
        titleLabel.text = article.title
        authorsLabel.text = article.authors
        websiteLabel.text = article.website
        dateLabel.text = article.date.formatDate()
        
        return cell
    }
    
    // Action sheet delegate
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        println("selected option \(buttonIndex)")
        
        var descriptor: NSSortDescriptor
        
        switch buttonIndex {
        case 1:
            descriptor = NSSortDescriptor(key: "authors", ascending: true)
        case 2:
            descriptor = NSSortDescriptor(key: "date", ascending: true)
        case 3:
            descriptor = NSSortDescriptor(key: "title", ascending: true)
        case 4:
            descriptor = NSSortDescriptor(key: "website", ascending: true)
        default:
            descriptor = NSSortDescriptor(key: "authors", ascending: true)
        }
        
        var sortedResults: NSArray = self.articlesArray!.sortedArrayUsingDescriptors([descriptor])
        
        self.articlesArray = NSArray(array: sortedResults)
        self.tableView!.reloadData()
    }
    
}

